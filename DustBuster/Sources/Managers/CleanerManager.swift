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
        "sessions",
        "autofill"
    ]

    /// Apple sistem servislerinin önbellekleri: silmek güvenli ama macOS yeniden indirir/üretir.
    /// Bu yüzden listelenir fakat varsayılan olarak seçimsiz gelir.
    private let appleSystemCacheNames: Set<String> = [
        "cloudkit", "geoservices", "animoji", "familycircled", "familycircle", "passkit",
        "gamekit", "sharedimagecache", "mbuseragent", "jetpackcache", "amsdatamigratortool",
        "askpermissiond", "trickplay", "arfilecache", "lsmimagecache", "ssu", "tvapp_bag",
        "features_config", "menkaure.enabled"
    ]

    /// Chromium profil klasörü içindeki cache alt klasörleri (Default/, Profile N/ …)
    private let chromiumProfileCacheFolders: [String] = [
        "Cache", "Code Cache", "GPUCache"
    ]

    /// Chromium tarayıcı kökündeki (profil dışı) cache klasörleri
    private let chromiumRootCacheFolders: [String] = [
        "ShaderCache", "GrShaderCache", "GraphiteDawnCache", "DawnWebGPUCache", "DawnGraphiteCache"
    ]

    /// Profil klasörü yerine kökü doğrudan profil olarak kullanan Chromium tarayıcılar
    /// (Electron uygulamaları da aynı yapıyı kullandığı için yalnızca bilinen tarayıcılar)
    private let chromiumSingleProfileRoots: Set<String> = [
        "com.operasoftware.opera", "com.operasoftware.operagx", "com.operasoftware.operaair",
        "com.operasoftware.operadeveloper", "com.operasoftware.operanext"
    ]

    /// Gecko tabanlı tarayıcılar (Firefox ailesi) - ~/Library/Caches altında
    private let geckoBasePaths: [String]

    /// Safari cache path'leri
    private let safariCachePaths: [String]

    // MARK: - Init

    init() {
        let home = NSHomeDirectory()

        // Genel, tüm uygulamalar için geçerli güvenli temizlik alanları
        // /private/var/log bilinçli olarak kapsam dışı: root'a ait, Tam Disk Erişimi okuma verir
        // ama silme yetkisi vermez; oradaki hiçbir öğe taşınamıyordu.
        self.baseAllowedPaths = [
            home + "/Library/Caches",   // Uygulama cache'leri
            home + "/Library/Logs"      // Kullanıcı log'ları
        ]

        // Gecko tabanlı tarayıcıların cache kökleri
        self.geckoBasePaths = [
            home + "/Library/Caches/Firefox/Profiles",
            home + "/Library/Caches/LibreWolf/Profiles",
            home + "/Library/Caches/Waterfox/Profiles",
            home + "/Library/Caches/Pale Moon/Profiles"
        ]

        // Safari cache path'leri: Safari sandbox'ta çalıştığı için gerçek cache konteynerin içinde;
        // ~/Library/Caches/com.apple.Safari eski sürümler için kalıyor (genelde boş kabuk).
        self.safariCachePaths = [
            home + "/Library/Containers/com.apple.Safari/Data/Library/Caches/com.apple.Safari",
            home + "/Library/Caches/com.apple.Safari"
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

            // 5) Temel path'leri tara (~/Library/Caches, ~/Library/Logs)
            for basePath in self.baseAllowedPaths {
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

        let isSystemService = isAppleSystemCache(path: item.path)
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

    /// ~/Library/Caches altındaki Apple sistem servisi önbelleği mi?
    private func isAppleSystemCache(path: String) -> Bool {
        let cachesRoot = NSHomeDirectory() + "/Library/Caches"
        guard isPath(path, under: cachesRoot) else { return false }
        let name = URL(fileURLWithPath: path).lastPathComponent.lowercased()
        if name.hasPrefix("com.apple.") { return true }
        return appleSystemCacheNames.contains(name)
    }

    /// Dizin sınırına saygılı önek karşılaştırması ("…/Caches/com.apple.Safari" ⊄ "…/Caches/com.apple.Safari.SafeBrowsing").
    private func isPath(_ path: String, under root: String) -> Bool {
        path == root || path.hasPrefix(root + "/")
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

    /// ~/Library/Application Support altındaki Chromium tabanlı tarayıcıları dinamik olarak tespit eder.
    /// İki seviye bakılır: `Google/Chrome`, `BraveSoftware/Brave-Browser` gibi geliştirici klasörü
    /// içinde duran tarayıcılar da yakalanır. Bir klasör ancak `Local State` dosyası ve en az bir
    /// profil klasörü (Default, Profile N, Guest Profile, System Profile) taşıyorsa tarayıcı sayılır;
    /// tek profilli yapı kullanan Opera ailesi ad listesiyle tanınır.
    private func detectDynamicBrowserCaches() {
        dynamicBrowserCachePaths.removeAll()
        let home = NSHomeDirectory()
        let appSupportPath = home + "/Library/Application Support"
        let fileManager = FileManager.default

        guard let level1 = try? fileManager.contentsOfDirectory(atPath: appSupportPath) else {
            return
        }

        var roots: [String] = []
        for name in level1 where !name.hasPrefix(".") && !name.lowercased().hasPrefix("com.apple.") {
            let path = appSupportPath + "/" + name
            guard isDirectory(path) else { continue }
            roots.append(path)
            if let level2 = try? fileManager.contentsOfDirectory(atPath: path) {
                for sub in level2 where !sub.hasPrefix(".") && !sub.lowercased().hasPrefix("com.apple.") {
                    let subPath = path + "/" + sub
                    if isDirectory(subPath) { roots.append(subPath) }
                }
            }
        }

        for root in roots {
            collectChromiumCaches(browserRoot: root)
        }

        logManager.log("Dinamik tarayıcı tespiti: \(dynamicBrowserCachePaths.count) Chromium cache bulundu", category: .cleanup, level: .info)
    }

    private func collectChromiumCaches(browserRoot: String) {
        let fileManager = FileManager.default
        guard let children = try? fileManager.contentsOfDirectory(atPath: browserRoot) else { return }

        let hasLocalState = fileManager.fileExists(atPath: browserRoot + "/Local State")
        let profileDirs = children.filter { name in
            name == "Default" || name.hasPrefix("Profile ") || name == "Guest Profile" || name == "System Profile"
        }

        func addIfDirectory(_ path: String) {
            guard isDirectory(path), !dynamicBrowserCachePaths.contains(path) else { return }
            dynamicBrowserCachePaths.append(path)
            #if DEBUG
            print("Chromium cache tespit edildi: \(path)")
            #endif
        }

        if hasLocalState && !profileDirs.isEmpty {
            for profile in profileDirs {
                for folder in chromiumProfileCacheFolders {
                    addIfDirectory(browserRoot + "/" + profile + "/" + folder)
                }
            }
            for folder in chromiumRootCacheFolders {
                addIfDirectory(browserRoot + "/" + folder)
            }
            return
        }

        let rootName = URL(fileURLWithPath: browserRoot).lastPathComponent.lowercased()
        if chromiumSingleProfileRoots.contains(rootName) {
            for folder in chromiumProfileCacheFolders + chromiumRootCacheFolders {
                addIfDirectory(browserRoot + "/" + folder)
            }
        }
    }

    private func isDirectory(_ path: String) -> Bool {
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue
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
                    // Safari cache'leri (dizin sınırına saygılı: com.apple.Safari.SafeBrowsing hariç tutulmaz)
                    if safariCachePaths.contains(where: { isPath(path, under: $0) || isPath($0, under: path) }) {
                        continue
                    }

                    // Gecko cache'leri
                    if geckoBasePaths.contains(where: { isPath(path, under: $0) || isPath($0, under: path) }) {
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
        let home = NSHomeDirectory()

        // 1) Mutlaka whitelist içindeki köklerden biriyle başlamalı
        //    (base paths + dinamik tespit edilen tarayıcı cache'leri + gecko + safari)
        let isUnderAllowedBase = allowedBasePaths.contains { allowed in
            isPath(path, under: allowed)
        }
        let isGeckoCache = geckoBasePaths.contains { geckoBase in
            isPath(path, under: geckoBase)
        }
        let isSafariCache = safariCachePaths.contains { safariPath in
            isPath(path, under: safariPath)
        }

        guard isUnderAllowedBase || isGeckoCache || isSafariCache else {
            return "izin verilen kökler dışında"
        }

        // 2) Asla dokunulmaması gereken köklerle başlamamalı
        //    Not: Safari cache ~/Library/Caches altında, ~/Library/Safari değil
        if let forbidden = forbiddenPaths.first(where: { path.hasPrefix($0) }), !isSafariCache {
            return "yasaklı kök: \(forbidden)"
        }

        // 3) Kullanıcı home veya root asla silinmesin
        if path == home || path == "/" {
            return "home veya kök dizin"
        }

        // 4) Application Support içindeyse sadece dinamik tespit edilen cache köklerinin altında olmalı
        if path.contains("/Library/Application Support/") {
            let isInDynamicCache = dynamicBrowserCachePaths.contains { allowedCache in
                path.hasPrefix(allowedCache)
            }
            if !isInDynamicCache {
                return "Application Support içinde, tespit edilen tarayıcı cache kökü değil"
            }
        }

        // 5) ~/Library/Caches altında history/cookies/login gibi şüpheli keyword içeriyorsa silme
        let cachesRoot = home + "/Library/Caches"
        if path.hasPrefix(cachesRoot) {
            if let keyword = sensitiveKeywords.first(where: { path.localizedCaseInsensitiveContains($0) }) {
                return "hassas kelime: \(keyword)"
            }
        }

        // 6) macOS "deletable" olarak işaretlemiyorsa silme
        if !FileManager.default.isDeletableFile(atPath: path) {
            return "macOS silinebilir işaretlemiyor"
        }

        return nil
    }

    // MARK: - Rapor (dışa aktarma)

    /// Taranan konumlar ve uygulanan kurallar.
    func scanScopeLines() -> [String] {
        let fm = FileManager.default
        var lines: [String] = []
        for base in baseAllowedPaths {
            lines.append("- \(base)" + (fm.fileExists(atPath: base) ? "" : " (yok)"))
        }
        lines.append("- Chromium cache kökleri, Application Support içinde tespit edilen (\(dynamicBrowserCachePaths.count)):")
        for path in dynamicBrowserCachePaths {
            lines.append("    \(path)")
        }
        let gecko = geckoBasePaths.filter { fm.fileExists(atPath: $0) }
        lines.append("- Gecko profil kökleri, mevcut (\(gecko.count)):")
        for path in gecko {
            lines.append("    \(path)")
        }
        let safari = safariCachePaths.filter { fm.fileExists(atPath: $0) }
        lines.append("- Safari cache yolları, mevcut (\(safari.count)):")
        for path in safari {
            lines.append("    \(path)")
        }
        lines.append("- Hassas anahtar kelimeler (~/Library/Caches altında engeller): " + sensitiveKeywords.joined(separator: ", "))
        lines.append("- Yasaklı kökler: " + forbiddenPaths.joined(separator: ", "))
        return lines
    }

    /// Her tarama kökünün üst düzey girdileri ve verilen karar (listelendi / atlandı + neden).
    /// Eşleştiricinin neyi neden dışarıda bıraktığını görmek için.
    func diagnosticListing(plan: CleaningPlan?) -> [String] {
        let fm = FileManager.default
        var lines: [String] = []

        var planSizes: [String: Int64] = [:]
        for candidate in plan?.candidates ?? [] {
            planSizes[candidate.path] = candidate.size
        }

        for basePath in baseAllowedPaths {
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
                let isBrowserRoot = safariCachePaths.contains { isPath(path, under: $0) || isPath($0, under: path) }
                    || geckoBasePaths.contains { isPath(path, under: $0) || isPath($0, under: path) }
                if isBrowserRoot {
                    lines.append("AYRI    | tarayıcı cache, kendi bölümünde ele alındı | \(name)")
                    continue
                }
                if let reason = safetyVerdict(path: path) {
                    lines.append("ATLANDI | \(reason) | \(name)")
                    continue
                }
                if let size = planSizes[path] {
                    lines.append("LİSTE   | \(ByteCountFormatter.string(fromByteCount: size, countStyle: .file)) | \(name)")
                } else {
                    lines.append("ATLANDI | boyut 0, symlink veya kimlik alınamadı | \(name)")
                }
            }
            lines.append("")
        }

        return lines
    }
}
