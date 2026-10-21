// Sources/Managers/CleanerManager.swift

import Foundation
import Combine
import DustBusterCore

/// Manages safe file deletion and system cleaning.
class CleanerManager: ObservableObject {

    // ObservableObject requirement
    let objectWillChange = ObservableObjectPublisher()
    private let permissionManager = PermissionManager.shared
    private let logManager = LogManager.shared
    private let safeDeleteService = SafeDeleteService()
    private let historyStore = TrashHistoryStore.shared

    struct TrashMoveRecord {
        let originalURL: URL
        let trashedURL: URL
        let size: Int64?
        let displayName: String
    }

    struct TrashTransaction {
        let id: UUID
        let date: Date
        let items: [TrashMoveRecord]
        let totalBytes: Int64
    }

    // MARK: - Kurallar

    /// Kurallar (rules.json) ve onları diske uygulayan politika; tüm karar mantığı DustBusterCore'dadır.
    private let policy: CleanupPolicy
    private let rulesLoaded: Bool

    // MARK: - Init

    init() {
        let home = NSHomeDirectory()
        if let rules = CleanupRules.bundled() {
            policy = CleanupPolicy(rules: rules, home: home, fs: RealFileSystem())
            rulesLoaded = true
        } else {
            policy = CleanupPolicy(rules: CleanerManager.fallbackRules, home: home, fs: RealFileSystem())
            rulesLoaded = false
        }
    }

    /// rules.json okunamazsa yalnızca iki kök ve yasaklı kökler ile çalışılır; tarayıcı ve satıcı kuralları devre dışı kalır.
    private static let fallbackRules = CleanupRules(
        roots: [CleanupRules.Root(path: "~/Library/Caches", label: "Caches"), CleanupRules.Root(path: "~/Library/Logs", label: "Logs")],
        forbiddenRoots: ["/System", "/Library", "/bin", "/sbin", "/usr", "/Applications"],
        sensitiveKeywords: ["history", "bookmark", "bookmarks", "cookies", "keychain", "account", "accounts", "login", "logindata", "sessions", "autofill"],
        appleServicePrefixes: ["com.apple."],
        appleServiceExceptions: ["com.apple.dt."],
        appleServiceNames: [],
        vendorFolders: [],
        browsers: CleanupRules.Browsers(chromiumProfileCacheFolders: [], chromiumRootCacheFolders: [], chromiumProfileNames: [],
                                        chromiumProfilePrefixes: [], chromiumSingleProfileRoots: [], chromiumNames: [:],
                                        geckoProfileRoots: [], geckoCacheFolder: "cache2", geckoNames: [:], safariCachePaths: [])
    )

    var rulesDescription: String {
        rulesLoaded ? "rules.json: \(policy.rules.roots.count) kök, \(policy.rules.vendorFolders.count) satıcı klasörü, \(policy.rules.browsers.chromiumNames.count) Chromium tanımı"
                    : "rules.json: yüklenemedi, yedek kurallar"
    }

    // MARK: - Public API

    /// Whitelist'e göre tüm hedef alanları tarar ve silinebilecek item listesini döner.
    func scan(completion: @escaping (CleaningPlan) -> Void) {
        permissionManager.checkFullDiskAccess()
        if permissionManager.hasFullDiskAccess == false {
            #if DEBUG
            print("Full Disk Access yok, sistem temizliği taraması iptal edildi")
            #endif
            logManager.log("Cleanup scan blocked: Full Disk Access yok", category: .audit, level: .warning)
            DispatchQueue.main.async {
                completion(CleaningPlan(candidates: []))
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.logManager.log("Cleanup scan başladı", category: .cleanup, level: .info)
            var items: [FileItem] = []

            let chromium = self.policy.detectChromiumCaches()
            self.logManager.log("Dinamik tarayıcı tespiti: \(chromium.count) Chromium cache bulundu", category: .cleanup, level: .info)

            var seenPaths = Set<String>()
            for candidate in self.policy.browserCandidates() + self.policy.rootCandidates() {
                guard seenPaths.insert(candidate.path).inserted else { continue }
                guard self.isSafeToDelete(path: candidate.path) else { continue }
                let url = URL(fileURLWithPath: candidate.path)
                let size = self.getPathSize(url: url)
                guard size > 0 else { continue }
                let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                items.append(FileItem(url: url, size: size, isDirectory: isDir, label: candidate.label))
            }

            let totalSize = items.reduce(Int64(0)) { $0 + $1.size }
            let sizeText = ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
            self.logManager.log("Cleanup scan tamamlandı: \(items.count) kayıt, \(sizeText)", category: .cleanup, level: .info)

            let plan = self.buildPlan(from: items)

            DispatchQueue.main.async {
                completion(plan)
            }
        }
    }
    
    /// Verilen temizlik planını güvenlik kuralları ile uygular.
    func apply(plan: CleaningPlan, completion: @escaping (CleaningResult) -> Void) {
        permissionManager.checkFullDiskAccess()
        if permissionManager.hasFullDiskAccess == false {
            #if DEBUG
            print("Full Disk Access yok, sistem temizliği iptal edildi")
            #endif
            logManager.log("Cleanup iptal edildi: Full Disk Access yok", category: .audit, level: .warning)
            let skipped = plan.selectedCandidates
            let emptyResult = CleaningResult(moved: [], skipped: skipped, failed: [], totalMovedBytes: 0, notes: [])
            DispatchQueue.main.async {
                completion(emptyResult)
            }
            return
        }

        let rules = SafeDeleteService.Rules(
            forbiddenPaths: policy.forbiddenRoots,
            isPathAllowed: { [weak self] path in
                guard let self = self else { return false }
                return self.isSafeToDelete(path: path)
            }
        )

        safeDeleteService.moveToTrash(plan: plan, rules: rules) { [weak self] result in
            guard let self = self else { return }
            self.logManager.log("Temizlik uygulandı: \(result.summaryLine)", category: .audit, level: .info)
            let movedText = ByteCountFormatter.string(fromByteCount: result.totalMovedBytes, countStyle: .file)
            self.logManager.log("Cleanup bitti: \(movedText) Çöp Kutusu'na taşındı", category: .cleanup, level: .info)
            let historyEntries = self.buildHistoryEntries(from: result)
            if historyEntries.isEmpty == false {
                _ = self.historyStore.append(historyEntries)
                self.logManager.log("History eklendi: \(historyEntries.count) kayıt", category: .audit, level: .info)
            }
            completion(result)
        }
    }

    func loadHistory() -> [TrashHistoryEntry] {
        historyStore.load()
    }

    func removeHistory(id: UUID) -> [TrashHistoryEntry] {
        historyStore.remove(id)
    }

    func restore(entry: TrashHistoryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fm = FileManager.default

            if fm.fileExists(atPath: entry.originalURL.path) {
                let error = NSError(domain: "DustBuster.Restore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Hedef konumda zaten bir dosya var."])
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            if self.isSymlink(entry.trashedURL) || self.isSymlink(entry.originalURL) {
                let error = NSError(domain: "DustBuster.Restore", code: 2, userInfo: [NSLocalizedDescriptionKey: "Symlink restore edilmiyor."])
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            do {
                try fm.createDirectory(at: entry.originalURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                try fm.moveItem(at: entry.trashedURL, to: entry.originalURL)
                _ = self.historyStore.remove(entry.id)
                DispatchQueue.main.async { completion(.success(())) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    // MARK: - Plan building

    private func buildPlan(from items: [FileItem]) -> CleaningPlan {
        let candidates: [CleaningCandidate] = items.compactMap { item in
            makeCandidate(from: item)
        }
        return CleaningPlan(candidates: candidates)
    }

    private func makeCandidate(from item: FileItem) -> CleaningCandidate? {
        guard let identity = FileIdentitySnapshot(url: item.url) else {
            logManager.log("Plan skip: kimlik alınamadı", category: .audit, level: .warning)
            return nil
        }

        if identity.isSymbolicLink {
            logManager.log("Plan skip: symlink bulundu", category: .audit, level: .warning)
            return nil
        }

        let isSystemService = policy.isAppleService(path: item.path)
        return CleaningCandidate(
            url: item.url,
            size: item.size,
            isDirectory: item.isDirectory,
            isSelected: item.isSelected && !isSystemService,
            displayName: item.displayName,
            identity: identity,
            isSystemService: isSystemService
        )
    }

    private func buildHistoryEntries(from result: CleaningResult) -> [TrashHistoryEntry] {
        result.moved.compactMap { movedItem in
            guard let trashedURL = movedItem.trashedURL else { return nil }
            return TrashHistoryEntry(
                originalURL: movedItem.candidate.url,
                trashedURL: trashedURL,
                size: movedItem.candidate.size,
                displayName: movedItem.candidate.displayName
            )
        }
    }

    func makeTransaction(from result: CleaningResult) -> TrashTransaction? {
        let records: [TrashMoveRecord] = result.moved.compactMap { movedItem in
            guard let trashedURL = movedItem.trashedURL else { return nil }
            return TrashMoveRecord(
                originalURL: movedItem.candidate.url,
                trashedURL: trashedURL,
                size: movedItem.candidate.size,
                displayName: movedItem.candidate.displayName
            )
        }
        guard !records.isEmpty else { return nil }
        return TrashTransaction(id: UUID(), date: Date(), items: records, totalBytes: result.totalMovedBytes)
    }

    func undo(transaction: TrashTransaction, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fm = FileManager.default
            var errors: [Error] = []

            for record in transaction.items {
                let original = record.originalURL.standardizedFileURL
                let trashed = record.trashedURL.standardizedFileURL

                if self.isSymlink(original) || self.isSymlink(trashed) {
                    continue
                }

                guard fm.fileExists(atPath: trashed.path) else { continue }

                let target = self.safeRestoreTarget(for: original, fileManager: fm)

                do {
                    try fm.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
                    try fm.moveItem(at: trashed, to: target)
                } catch {
                    errors.append(error)
                }
            }

            if errors.isEmpty {
                let trashedPaths = Set(transaction.items.map { $0.trashedURL.standardizedFileURL.path })
                _ = self.historyStore.remove(trashedPaths: trashedPaths)
                self.logManager.log("Undo başarı: \(transaction.items.count) öğe", category: .audit, level: .info)
                DispatchQueue.main.async { completion(.success(())) }
            } else {
                let first = errors.first!
                self.logManager.log("Undo hata: \(first.localizedDescription)", category: .error, level: .error)
                DispatchQueue.main.async { completion(.failure(first)) }
            }
        }
    }

    private func safeRestoreTarget(for original: URL, fileManager: FileManager) -> URL {
        if !fileManager.fileExists(atPath: original.path) {
            return original
        }
        let base = original.deletingPathExtension()
        let ext = original.pathExtension.isEmpty ? nil : original.pathExtension
        var counter = 1
        while true {
            let candidateName = "\(base.lastPathComponent) (Restored \(counter))"
            var candidate = base.deletingLastPathComponent().appendingPathComponent(candidateName)
            if let ext { candidate.appendPathExtension(ext) }
            if !fileManager.fileExists(atPath: candidate.path) {
                return candidate
            }
            counter += 1
        }
    }

    private func isSymlink(_ url: URL) -> Bool {
        let values = try? url.resourceValues(forKeys: [.isSymbolicLinkKey])
        return values?.isSymbolicLink ?? false
    }
    
    // MARK: - Boyut

    /// Dosya veya klasörün recursive boyutunu hesaplar. Tekil dosyalar doğrudan ölçülür,
    /// symlink'ler sayılmaz.
    private func getPathSize(url: URL) -> Int64 {
        let fileManager = FileManager.default
        let keys: Set<URLResourceKey> = [.isDirectoryKey, .isSymbolicLinkKey, .fileSizeKey]

        guard let values = try? url.resourceValues(forKeys: keys) else { return 0 }
        if values.isSymbolicLink == true { return 0 }
        if values.isDirectory != true {
            return Int64(values.fileSize ?? 0)
        }

        var size: Int64 = 0
        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: Array(keys)) {
            for case let fileURL as URL in enumerator {
                guard let resourceValues = try? fileURL.resourceValues(forKeys: keys) else { continue }
                if resourceValues.isSymbolicLink == true { continue }
                if resourceValues.isDirectory == true { continue }
                size += Int64(resourceValues.fileSize ?? 0)
            }
        }
        return size
    }
    
    // MARK: - Core Safety Check

    /// Tüm güvenlik kurallarını uygular.
    /// Sadece gerçekten silinmesi güvenli path'ler için true döner.
    private func isSafeToDelete(path: String) -> Bool {
        safetyVerdict(path: path) == nil
    }

    /// Güvenlik kararı: nil ise silinebilir, değilse neden silinemeyeceğini açıklayan kısa metin.
    /// (isSafeToDelete ve rapor çıktısı aynı kaynağı kullanır.)
    func safetyVerdict(path: String) -> String? {
        if let reason = policy.verdict(path: path) { return reason }
        if !FileManager.default.isDeletableFile(atPath: path) {
            return "macOS silinebilir işaretlemiyor"
        }
        return nil
    }

    // MARK: - Rapor (dışa aktarma)

    /// Taranan konumlar ve uygulanan kurallar.
    func scanScopeLines() -> [String] {
        [rulesDescription] + policy.scopeLines()
    }

    /// Her tarama kökünün üst düzey girdileri ve verilen karar (listelendi / atlandı + neden / bölündü).
    /// Eşleştiricinin neyi neden dışarıda bıraktığını görmek için.
    func diagnosticListing(plan: CleaningPlan?) -> [String] {
        let fm = FileManager.default
        var lines: [String] = []

        var planSizes: [String: Int64] = [:]
        for candidate in plan?.candidates ?? [] {
            planSizes[candidate.path] = candidate.size
        }

        func line(for path: String, name: String, indent: String = "") {
            if let reason = safetyVerdict(path: path) {
                lines.append("\(indent)ATLANDI | \(reason) | \(name)")
            } else if let size = planSizes[path] {
                lines.append("\(indent)LİSTE   | \(ByteCountFormatter.string(fromByteCount: size, countStyle: .file)) | \(name)")
            } else {
                lines.append("\(indent)ATLANDI | boyut 0, symlink veya kimlik alınamadı | \(name)")
            }
        }

        for root in policy.rules.roots {
            let basePath = policy.expand(root.path)
            guard fm.fileExists(atPath: basePath) else {
                lines.append("\(basePath): yok")
                lines.append("")
                continue
            }
            guard let names = try? fm.contentsOfDirectory(atPath: basePath) else {
                lines.append("\(basePath): okunamadı (Tam Disk Erişimi?)")
                lines.append("")
                continue
            }

            let visible = names.filter { !$0.hasPrefix(".") }
                .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
            lines.append("\(basePath) — üst düzey girdiler (\(visible.count))")

            for name in visible {
                let path = basePath + "/" + name
                switch policy.decide(rootEntry: path, rootLabel: root.label) {
                case .browser:
                    lines.append("AYRI    | tarayıcı cache, kendi bölümünde ele alındı | \(name)")
                case .split(let children):
                    lines.append("BÖLÜNDÜ | satıcı klasörü, alt girdiler ayrı listelendi (\(children.count)) | \(name)")
                    for child in children {
                        line(for: child.path, name: (child.path as NSString).lastPathComponent, indent: "    ")
                    }
                case .listed:
                    line(for: path, name: name)
                }
            }
            lines.append("")
        }

        return lines
    }
}
