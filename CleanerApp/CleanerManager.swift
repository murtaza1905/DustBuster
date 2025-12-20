// Sources/Managers/CleanerManager.swift

import Foundation
import Combine

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

    // MARK: - Paths & Safety Rules

    /// Temel whitelist path'leri (Caches, Logs, vs.)
    private let baseAllowedPaths: [String]

    /// Dinamik olarak tespit edilen tarayıcı cache path'leri
    private var dynamicBrowserCachePaths: [String] = []

    /// Tüm izin verilen path'ler (base + dinamik)
    private var allowedBasePaths: [String] {
        baseAllowedPaths + dynamicBrowserCachePaths
    }

    /// Asla dokunulmaması gereken path kökleri (sistem + kullanıcı verisi).
    private let forbiddenPaths: [String]

    /// Cache path'lerinde geçerse riskli sayılacak anahtar kelimeler.
    /// (İhtiyaten history / cookies / login vb. içeren cache path'lerini de bloklar)
    private let sensitiveKeywords: [String] = [
        "history",
        "bookmark",
        "bookmarks",
        "cookies",
        "keychain",
        "account",
        "accounts",
        "login",
        "logindata",
        "session",
        "sessions",
        "autofill"
    ]

    /// Chromium tabanlı tarayıcılarda aranan cache klasör yapıları
    private let chromiumCachePatterns: [String] = [
        "Default/Cache",
        "Default/Code Cache",
        "Default/GPUCache",
        "User Data/Default/Cache",
        "User Data/Default/Code Cache",
        "User Data/Default/GPUCache"
    ]

    /// Gecko tabanlı tarayıcılar (Firefox ailesi) - ~/Library/Caches altında
    private let geckoBasePaths: [String]

    /// Safari cache path'leri
    private let safariCachePaths: [String]

    // MARK: - Init

    init() {
        let home = NSHomeDirectory()

        // Genel, tüm uygulamalar için geçerli güvenli temizlik alanları
        self.baseAllowedPaths = [
            home + "/Library/Caches",   // Uygulama cache'leri
            home + "/Library/Logs",     // Kullanıcı log'ları
            "/private/var/log"          // Sistem log'ları (Full Disk Access ile)
        ]

        // Gecko tabanlı tarayıcıların cache kökleri
        self.geckoBasePaths = [
            home + "/Library/Caches/Firefox/Profiles",
            home + "/Library/Caches/LibreWolf/Profiles",
            home + "/Library/Caches/Waterfox/Profiles",
            home + "/Library/Caches/Pale Moon/Profiles"
        ]

        // Safari cache path'leri
        self.safariCachePaths = [
            home + "/Library/Caches/com.apple.Safari",
            home + "/Library/Caches/com.apple.Safari/WebKitCache"
        ]

        // Asla dokunulmaması gereken path kökleri
        self.forbiddenPaths = [
            "/System",
            "/Library",
            "/bin",
            "/sbin",
            "/usr",
            "/Applications"
        ]
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
            let fileManager = FileManager.default

            // 1) Dinamik tarayıcı cache'lerini tespit et
            self.detectDynamicBrowserCaches()

            // 2) Chromium tabanlı tarayıcı cache'lerini tara
            let chromiumItems = self.scanChromiumBrowserCaches()
            items.append(contentsOf: chromiumItems)

            // 3) Gecko tabanlı tarayıcı cache'lerini tara (Firefox ailesi)
            let geckoItems = self.scanGeckoBrowserCaches()
            items.append(contentsOf: geckoItems)

            // 4) Safari cache'lerini tara
            let safariItems = self.scanSafariCaches()
            items.append(contentsOf: safariItems)

            // 5) Temel path'leri tara (~/Library/Caches, ~/Library/Logs, /private/var/log)
            for basePath in self.baseAllowedPaths {
                if basePath.hasPrefix("/private/var/log"),
                   self.permissionManager.hasFullDiskAccess == false {
                    print("Full Disk Access yok, /private/var/log taranmadı")
                    continue
                }

                guard fileManager.fileExists(atPath: basePath) else { continue }
                let url = URL(fileURLWithPath: basePath)

                // ~/Library/Caches içeriğini tara (tarayıcı cache'leri hariç - zaten eklendi)
                let foundItems = self.scanDirectory(at: url, excludeBrowserCaches: true)
                items.append(contentsOf: foundItems)
            }

            // Duplicate'leri kaldır (path bazlı)
            var seenPaths = Set<String>()
            items = items.filter { item in
                if seenPaths.contains(item.path) {
                    return false
                }
                seenPaths.insert(item.path)
                return true
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
            forbiddenPaths: forbiddenPaths,
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

        return CleaningCandidate(
            url: item.url,
            size: item.size,
            isDirectory: item.isDirectory,
            isSelected: item.isSelected,
            displayName: item.displayName,
            identity: identity
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
    
    // MARK: - Dynamic Browser Detection

    /// ~/Library/Application Support altındaki Chromium tabanlı tarayıcıları dinamik olarak tespit eder
    private func detectDynamicBrowserCaches() {
        dynamicBrowserCachePaths.removeAll()
        let home = NSHomeDirectory()
        let appSupportPath = home + "/Library/Application Support"
        let fileManager = FileManager.default

        guard let contents = try? fileManager.contentsOfDirectory(atPath: appSupportPath) else {
            return
        }

        for folderName in contents {
            let folderPath = appSupportPath + "/" + folderName

            // Her Chromium cache pattern'ini kontrol et
            for pattern in chromiumCachePatterns {
                let cachePath = folderPath + "/" + pattern

                if fileManager.fileExists(atPath: cachePath) {
                    // Bu bir Chromium tabanlı tarayıcı cache'i
                    dynamicBrowserCachePaths.append(cachePath)
                    #if DEBUG
                    print("Chromium cache tespit edildi: \(cachePath)")
                    #endif
                }
            }
        }

        logManager.log("Dinamik tarayıcı tespiti: \(dynamicBrowserCachePaths.count) Chromium cache bulundu", category: .cleanup, level: .info)
    }

    /// Chromium tabanlı tarayıcı cache'lerini tarar
    private func scanChromiumBrowserCaches() -> [FileItem] {
        var results: [FileItem] = []

        for cachePath in dynamicBrowserCachePaths {
            let url = URL(fileURLWithPath: cachePath)
            guard isSafeToDelete(path: cachePath) else { continue }

            let size = getPathSize(url: url)
            if size > 0 {
                results.append(FileItem(url: url, size: size, isDirectory: true))
            }
        }

        return results
    }

    /// Gecko tabanlı tarayıcı cache'lerini tarar (Firefox, LibreWolf, Waterfox, Pale Moon)
    private func scanGeckoBrowserCaches() -> [FileItem] {
        var results: [FileItem] = []
        let fileManager = FileManager.default

        for geckoBasePath in geckoBasePaths {
            guard fileManager.fileExists(atPath: geckoBasePath) else { continue }

            // Profil klasörlerini tara
            guard let profiles = try? fileManager.contentsOfDirectory(atPath: geckoBasePath) else {
                continue
            }

            for profileName in profiles {
                let profilePath = geckoBasePath + "/" + profileName
                let cache2Path = profilePath + "/cache2"

                guard fileManager.fileExists(atPath: cache2Path) else { continue }
                guard isSafeToDelete(path: cache2Path) else { continue }

                let url = URL(fileURLWithPath: cache2Path)
                let size = getPathSize(url: url)
                if size > 0 {
                    results.append(FileItem(url: url, size: size, isDirectory: true))
                    #if DEBUG
                    print("Gecko cache tespit edildi: \(cache2Path)")
                    #endif
                }
            }
        }

        return results
    }

    /// Safari cache'lerini tarar
    private func scanSafariCaches() -> [FileItem] {
        var results: [FileItem] = []
        let fileManager = FileManager.default

        for safariPath in safariCachePaths {
            guard fileManager.fileExists(atPath: safariPath) else { continue }
            guard isSafeToDelete(path: safariPath) else { continue }

            let url = URL(fileURLWithPath: safariPath)
            let size = getPathSize(url: url)
            if size > 0 {
                results.append(FileItem(url: url, size: size, isDirectory: true))
                #if DEBUG
                print("Safari cache tespit edildi: \(safariPath)")
                #endif
            }
        }

        return results
    }

    // MARK: - Internal Scanning Logic

    /// Verilen dizinin sadece top-level içeriğini (alt klasörlerin kendisini) item olarak döner.
    private func scanDirectory(at url: URL, excludeBrowserCaches: Bool = false) -> [FileItem] {
        var results: [FileItem] = []
        let fileManager = FileManager.default

        let options: FileManager.DirectoryEnumerationOptions = [
            .skipsHiddenFiles,
            .skipsPackageDescendants,
            .skipsSubdirectoryDescendants
        ]

        do {
            let contents = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
                options: options
            )

            for fileURL in contents {
                let path = fileURL.path

                // Tarayıcı cache'lerini hariç tut (zaten ayrıca eklendi)
                if excludeBrowserCaches {
                    // Safari cache'leri
                    if safariCachePaths.contains(where: { path.hasPrefix($0) || $0.hasPrefix(path) }) {
                        continue
                    }

                    // Gecko cache'leri
                    if geckoBasePaths.contains(where: { path.hasPrefix($0) || $0.hasPrefix(path) }) {
                        continue
                    }

                    // Chromium cache'leri zaten Application Support'ta, Caches'te değil
                }

                guard isSafeToDelete(path: path) else { continue }

                let size = getPathSize(url: fileURL)
                if size <= 0 { continue }

                let isDir = (try? fileURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                results.append(FileItem(url: fileURL, size: size, isDirectory: isDir))
            }
        } catch {
            print("Scan error for \(url.path): \(error)")
        }

        return results
    }

    /// Dosya veya klasörün recursive boyutunu hesaplar.
    private func getPathSize(url: URL) -> Int64 {
        let fileManager = FileManager.default
        var size: Int64 = 0

        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                   let fileSize = resourceValues.fileSize {
                    size += Int64(fileSize)
                }
            }
        }
        return size
    }
    
    // MARK: - Core Safety Check

    /// Tüm güvenlik kurallarını uygular.
    /// Sadece gerçekten silinmesi güvenli path'ler için true döner.
    private func isSafeToDelete(path: String) -> Bool {
        let home = NSHomeDirectory()

        // 1) Mutlaka whitelist içindeki köklerden biriyle başlamalı
        //    (base paths + dinamik tespit edilen tarayıcı cache'leri + gecko + safari)
        let isUnderAllowedBase = allowedBasePaths.contains { allowed in
            path.hasPrefix(allowed)
        }

        // Gecko cache path'leri için özel kontrol
        let isGeckoCache = geckoBasePaths.contains { geckoBase in
            path.hasPrefix(geckoBase)
        }

        // Safari cache path'leri için özel kontrol
        let isSafariCache = safariCachePaths.contains { safariPath in
            path.hasPrefix(safariPath)
        }

        guard isUnderAllowedBase || isGeckoCache || isSafariCache else { return false }

        // 2) Asla dokunulmaması gereken köklerle başlamamalı
        //    Not: Safari cache ~/Library/Caches altında, ~/Library/Safari değil
        if forbiddenPaths.contains(where: { forbidden in path.hasPrefix(forbidden) }) {
            // Safari cache özel durumu - ~/Library/Safari yasak ama ~/Library/Caches/com.apple.Safari izinli
            if isSafariCache {
                // Safari cache'i için bu kontrolü atla
            } else {
                return false
            }
        }

        // 3) Kullanıcı home veya root asla silinmesin
        if path == home || path == "/" {
            return false
        }

        // 4) Application Support içindeyse sadece dinamik tespit edilen cache köklerinin altında olmalı
        if path.contains("/Library/Application Support/") {
            let isInDynamicCache = dynamicBrowserCachePaths.contains { allowedCache in
                path.hasPrefix(allowedCache)
            }
            if !isInDynamicCache {
                return false
            }
        }

        // 5) ~/Library/Caches altında history/cookies/login gibi şüpheli keyword içeriyorsa silme
        let cachesRoot = home + "/Library/Caches"
        if path.hasPrefix(cachesRoot) {
            if sensitiveKeywords.contains(where: { keyword in
                path.localizedCaseInsensitiveContains(keyword)
            }) {
                return false
            }
        }

        // 6) macOS "deletable" olarak işaretlemiyorsa silme
        if !FileManager.default.isDeletableFile(atPath: path) {
            return false
        }

        return true
    }
}
