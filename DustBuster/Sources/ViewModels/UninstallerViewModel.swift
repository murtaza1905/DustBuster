import Foundation
import AppKit
import UniformTypeIdentifiers
import Combine

struct UninstallResultSummary {
    let moved: Int
    let skipped: Int
    let failed: Int
    let messages: [String]
}

struct UninstallTransactionItem: Identifiable {
    let id = UUID()
    let originalURL: URL
    let trashedURL: URL
    let sizeBytes: Int64?
    let displayName: String
}

struct UninstallTransaction: Identifiable {
    let id = UUID()
    let date: Date
    let appName: String
    let items: [UninstallTransactionItem]
    let totalBytes: Int64

    var itemCount: Int { items.count }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
    }
}

final class UninstallerViewModel: ObservableObject {
    @Published var appURL: URL?
    @Published var appName: String = ""
    @Published var bundleIdentifier: String = ""
    @Published var errorMessage: String?
    @Published var items: [UninstallItem] = []
    @Published var isScanning: Bool = false
    @Published var isProcessing: Bool = false
    @Published var resultSummary: UninstallResultSummary?
    // MARK: - System Locations
    @Published var includeSystemLocations: Bool = false
    @Published var includeAggressiveLocations: Bool = false
    // MARK: - Undo Support
    @Published var uninstallHistory: [UninstallTransaction] = []  // Son 10 islem
    @Published var isUndoing: Bool = false
    @Published var undoError: String? = nil

    private let maxHistoryCount = 10
    private var scanGeneration: Int = 0
    private var sizeCache: [String: Int64] = [:]
    private var sizeInFlight: Set<String> = []
    private let sizeQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Uninstaller.SizeQueue"
        queue.maxConcurrentOperationCount = 2
        return queue
    }()

    // MARK: - Computed Properties
    
    /// Seçili öğelerin toplam sayısı
    var selectedCount: Int {
        items.filter { $0.isSelected }.count
    }
    
    /// Seçili öğelerin toplam boyutu (bytes)
    var selectedTotalBytes: Int64 {
        items.filter { $0.isSelected }.reduce(0) { $0 + ($1.sizeBytes ?? 0) }
    }
    
    private var hasUnknownSizes: Bool {
        items.contains { $0.sizeBytes == nil }
    }

    private var hasUnknownSelectedSizes: Bool {
        items.contains { $0.isSelected && $0.sizeBytes == nil }
    }
    
    /// Seçili öğelerin toplam boyutu (formatlanmış string)
    var selectedTotalSize: String {
        if hasUnknownSelectedSizes { return "Hesaplanıyor..." }
        return ByteCountFormatter.string(fromByteCount: selectedTotalBytes, countStyle: .file)
    }
    
    /// Tüm öğelerin toplam boyutu (bytes)
    var totalBytes: Int64 {
        items.reduce(0) { $0 + ($1.sizeBytes ?? 0) }
    }
    
    /// Tüm öğelerin toplam boyutu (formatlanmış string)
    var totalSize: String {
        if hasUnknownSizes { return "Hesaplanıyor..." }
        return ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
    }
    
    /// Geri alma yapılabilir mi?
    var canUndo: Bool {
        !uninstallHistory.isEmpty && !isUndoing && !isProcessing
    }
    
    /// Tüm geçmişi temizle
    func clearUndoHistory() {
        uninstallHistory.removeAll()
    }

    private let manager = UninstallerManager()
    private let safeDeleteService = SafeDeleteService()
    private let logManager = LogManager.shared

    // MARK: - Reset

    func reset() {
        appURL = nil
        appName = ""
        bundleIdentifier = ""
        items = []
        isScanning = false
        isProcessing = false
        resultSummary = nil
        errorMessage = nil
        // uninstallHistory'yi koruyoruz; diğer uygulamalar için geri alma mümkün kalsın.
    }

    // MARK: - Drop handling

    func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) }) else {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "Geçerli bir uygulama bulunamadı."
            }
            return false
        }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { [weak self] (item, error) in
            if let error = error {
                DispatchQueue.main.async { self?.errorMessage = error.localizedDescription }
                return
            }

            let url: URL?
            if let data = item as? Data {
                url = URL(dataRepresentation: data, relativeTo: nil)
            } else if let nsUrl = item as? NSURL {
                url = nsUrl as URL
            } else {
                url = nil
            }

            guard let appURL = url else {
                DispatchQueue.main.async { self?.errorMessage = "Geçersiz dosya." }
                return
            }

            DispatchQueue.main.async {
                self?.reset()
                self?.loadApp(at: appURL)
            }
        }

        return true
    }

    func loadApp(at url: URL) {
        guard let validated = validate(appURL: url) else { return }

        appURL = url
        appName = validated.name
        bundleIdentifier = validated.bundleId ?? ""
        errorMessage = nil
        resultSummary = nil

        scanItems(bundleId: validated.bundleId, appName: validated.name, appURL: url)
    }

    // MARK: - Actions

    func moveSelectedToTrash() {
        guard !isProcessing else { return }
        let selected = items.filter { $0.isSelected }
        guard !selected.isEmpty else {
            resultSummary = UninstallResultSummary(moved: 0, skipped: 0, failed: 0, messages: ["Secilmis oge yok."])
            return
        }

        isProcessing = true
        resultSummary = nil
        errorMessage = nil

        let urls = selected.map { $0.url }
        let allowedExtras = appURL.map { [$0] } ?? []
        let selectedLookup: [String: UninstallItem] = Dictionary(uniqueKeysWithValues: selected.map { ($0.url.standardizedFileURL.path, $0) })

        // Use smartMoveToTrash which handles AppleScript admin elevation automatically
        safeDeleteService.smartMoveToTrash(urls: urls, allowedOutsideHome: allowedExtras) { [weak self] result in
            guard let self = self else { return }

            let movedSet = Set(result.moved.map { $0.original })
            self.items.removeAll { movedSet.contains($0.url) }

            var messages: [String] = []

            // Handle user cancellation specially
            if result.userCancelled {
                messages.append("Kullanici admin yetkisi istemini iptal etti")
            }

            let errorMessages = result.failed.map { "\($0.url.lastPathComponent): \($0.error.localizedDescription) (kod \($0.error.code))" }
            let skipMessages = result.skipped.map { "\($0.url.lastPathComponent): \($0.reason)" }
            messages.append(contentsOf: errorMessages)
            messages.append(contentsOf: skipMessages)

            if messages.isEmpty {
                messages = result.notes
            }

            // Track which files used admin privileges
            let adminCount = result.moved.filter { $0.usedAdminPrivileges }.count
            if adminCount > 0 {
                self.logManager.log("Uninstaller: \(adminCount) dosya admin yetkisiyle silindi", category: .cleanup, level: .info)
            }

            let transactionItems: [UninstallTransactionItem] = result.moved.compactMap { moved in
                guard let trashed = moved.trashedURL else { return nil }
                let key = moved.original.standardizedFileURL.path
                let info = selectedLookup[key]
                return UninstallTransactionItem(
                    originalURL: moved.original,
                    trashedURL: trashed,
                    sizeBytes: info?.sizeBytes,
                    displayName: info?.displayName ?? moved.original.lastPathComponent
                )
            }
            let totalBytes = transactionItems.reduce(into: Int64(0)) { partial, item in
                partial += item.sizeBytes ?? 0
            }

            let summary = UninstallResultSummary(
                moved: result.moved.count,
                skipped: result.skipped.count,
                failed: result.failed.count,
                messages: Array(messages.prefix(5))
            )
            self.resultSummary = summary
            self.isProcessing = false

            // Show special error if user cancelled
            if result.userCancelled && result.moved.isEmpty {
                self.errorMessage = "Islem iptal edildi. Korumali dosyalar icin admin yetkisi gerekli."
            }

            let appLabel = self.appName.isEmpty ? "Bilinmeyen" : self.appName
            self.logManager.log("Uninstaller \(appLabel): \(summary.moved) tasindi / \(summary.skipped) atlandi / \(summary.failed) hata", category: .cleanup, level: .info)

            if !transactionItems.isEmpty {
                let transaction = UninstallTransaction(
                    date: Date(),
                    appName: appLabel,
                    items: transactionItems,
                    totalBytes: totalBytes
                )
                self.uninstallHistory.insert(transaction, at: 0)
                if self.uninstallHistory.count > self.maxHistoryCount {
                    self.uninstallHistory = Array(self.uninstallHistory.prefix(self.maxHistoryCount))
                }
            }

            if movedSet.contains(where: { $0 == self.appURL }) {
                self.reset()
            }
        }
    }

    /// Belirli bir kaldırma işlemini geri alır
    func undoUninstall(_ transaction: UninstallTransaction) {
        guard !isUndoing else { return }
        isUndoing = true
        undoError = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let fm = FileManager.default
            var restoredCount = 0
            var errors: [Error] = []

            for item in transaction.items {
                let original = item.originalURL.standardizedFileURL
                let trashed = item.trashedURL.standardizedFileURL

                if self.isSymlink(original) || self.isSymlink(trashed) {
                    continue
                }

                guard fm.fileExists(atPath: trashed.path) else { continue }

                let target = self.safeRestoreTarget(for: original, fileManager: fm)

                do {
                    try fm.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
                    try fm.moveItem(at: trashed, to: target)
                    restoredCount += 1
                } catch {
                    errors.append(error)
                }
            }

            DispatchQueue.main.async {
                self.isUndoing = false
                if restoredCount > 0 {
                    self.uninstallHistory.removeAll { $0.id == transaction.id }
                    self.resultSummary = nil
                    self.logManager.log("Uninstaller undo: \(restoredCount)/\(transaction.items.count) öğe geri alındı (\(transaction.appName))", category: .cleanup, level: .info)
                } else if let first = errors.first {
                    self.undoError = first.localizedDescription
                    self.logManager.log("Uninstaller undo hata: \(first.localizedDescription)", category: .error, level: .error)
                }
            }
        }
    }

    // MARK: - Private

    private func validate(appURL url: URL) -> (name: String, bundleId: String?)? {
        guard url.isFileURL else {
            errorMessage = "Sadece .app dosyalarını bırakabilirsin."
            return nil
        }

        guard url.pathExtension.lowercased() == "app" else {
            errorMessage = "Sadece .app dosyalarını bırakabilirsin."
            return nil
        }

        guard FileManager.default.isReadableFile(atPath: url.path) else {
            errorMessage = "Uygulama okunamıyor."
            return nil
        }

        guard let bundle = Bundle(url: url) else {
            errorMessage = "Uygulama bilgisi alınamadı."
            return nil
        }

        let name = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? url.deletingPathExtension().lastPathComponent

        errorMessage = nil
        return (name: name, bundleId: bundle.bundleIdentifier)
    }

    private func scanItems(bundleId: String?, appName: String, appURL: URL) {
        isScanning = true
        items = []
        errorMessage = nil
        resultSummary = nil

        manager.includeSystemLocations = includeSystemLocations
        manager.includeAggressiveLocations = includeAggressiveLocations

        scanGeneration += 1
        let currentGeneration = scanGeneration
        sizeQueue.cancelAllOperations()
        sizeInFlight.removeAll()
        sizeCache.removeAll()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let fast = self.manager.buildItemsFast(appURL: appURL, bundleId: bundleId, appName: appName)
            DispatchQueue.main.async {
                guard currentGeneration == self.scanGeneration else { return }
                self.items = fast
            }

            let deep = self.manager.buildItemsDeep(appURL: appURL, bundleId: bundleId, appName: appName)
            DispatchQueue.main.async {
                guard currentGeneration == self.scanGeneration else { return }
                let limit = UninstallerManager.maxReasonableResults
                if deep.count > limit {
                    // Güvenlik eşiği: bu kadar sonuç ancak eşleştirme hatasıyla çıkar.
                    // Yalnızca bundle ID ile birebir bulunan (hızlı tarama) öğeler listede kalır.
                    self.errorMessage = "Tarama \(deep.count) öğe buldu; bu sayı güvenlik sınırının (\(limit)) üzerinde. Yalnızca bundle ID ile birebir eşleşen öğeler listelendi."
                    self.logManager.log("Uninstaller: tarama sınırı aşıldı (\(deep.count) > \(limit)), derin sonuçlar atıldı", category: .audit, level: .warning)
                } else {
                    self.items = self.mergeByPathKeepingExisting(existing: self.items, incoming: deep)
                }
                self.isScanning = false
            }
        }
    }

    private func mergeByPathKeepingExisting(existing: [UninstallItem], incoming: [UninstallItem]) -> [UninstallItem] {
        var seen = Set(existing.map { $0.url.path })
        var merged = existing

        for item in incoming {
            let path = item.url.path
            guard !seen.contains(path) else { continue }
            seen.insert(path)
            merged.append(item)
        }

        return merged.sorted {
            if $0.isStrongMatch != $1.isStrongMatch { return $0.isStrongMatch }
            let a = kindRank($0.kind), b = kindRank($1.kind)
            if a != b { return a < b }
            return $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        }
    }

    private func kindRank(_ kind: UninstallItemKind) -> Int {
        switch kind {
        case .appBundle: return 0
        case .preferences, .preferencesByHost: return 1
        case .applicationSupport: return 2
        case .containers, .groupContainers: return 3
        case .caches: return 4
        case .logs: return 5
        case .savedState: return 6
        case .launchAgents: return 7
        default: return 50
        }
    }

    func requestSize(for itemId: UUID) {
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        if items[index].sizeBytes != nil { return }

        let url = items[index].url
        let path = url.path

        if let cached = sizeCache[path] {
            items[index].sizeBytes = cached
            return
        }

        if sizeInFlight.contains(path) { return }
        sizeInFlight.insert(path)

        let currentGeneration = scanGeneration
        let isAppBundle = (appURL?.standardizedFileURL.path == url.standardizedFileURL.path)
        sizeQueue.addOperation { [weak self] in
            guard let self = self else { return }
            let size = self.manager.computeSizeBytes(for: url, isAppBundle: isAppBundle)
            OperationQueue.main.addOperation {
                guard currentGeneration == self.scanGeneration else { return }
                self.sizeInFlight.remove(path)
                if let size {
                    self.sizeCache[path] = size
                    if let targetIndex = self.items.firstIndex(where: { $0.id == itemId }) {
                        self.items[targetIndex].sizeBytes = size
                    }
                }
            }
        }
    }

    private func isSymlink(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) ?? false
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
}
