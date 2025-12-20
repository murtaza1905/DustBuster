import Foundation

enum UninstallItemKind: String {
    case appBundle = "Uygulama Paketi"
    case applicationSupport = "Application Support"
    case caches = "Caches"
    case preferences = "Preferences"
    case preferencesByHost = "Preferences (ByHost)"
    case logs = "Logs"
    case savedState = "Saved Application State"
    case containers = "Containers"
    case groupContainers = "Group Containers"
    case launchAgents = "Launch Agents"
    case httpStorages = "HTTP Storages"
    case webKit = "WebKit"
    case cookies = "Cookies"
    case crashReports = "Crash Reports"
    case applicationScripts = "Application Scripts"
    case internetPlugins = "Internet Plug-Ins"
    case preferencePanes = "Preference Panes"
    case quickLook = "QuickLook"
    case screenSavers = "Screen Savers"
    case services = "Services"
    case spotlight = "Spotlight"
    case inputMethods = "Input Methods"
    case frameworks = "Frameworks"
    case colorPickers = "Color Pickers"
    case addressBookPlugins = "Address Book Plug-Ins"
    // Ek kullanici konumlari
    case mailBundles = "Mail Bundles"
    case developer = "Developer"
    // Sistem seviyesi konumlar (/Library/)
    case systemAppSupport = "System Application Support"
    case systemLaunchAgents = "System Launch Agents"
    case systemLaunchDaemons = "System Launch Daemons"
    case privilegedHelpers = "Privileged Helper Tools"
    case systemPreferences = "System Preferences"
    case systemFrameworks = "System Frameworks"
    case recentDocuments = "Recent Documents"
    case other = "Diger"
}

// MARK: - Search Terms Structure

struct SearchTerms {
    let exact: [String]
    let prefix: [String]
    let contains: [String]
    
    func matches(_ name: String) -> Bool {
        let nameLower = name.lowercased()
        
        for exact in exact {
            let exactLower = exact.lowercased()
            if nameLower == exactLower ||
               nameLower.hasPrefix(exactLower + ".") ||
               nameLower.hasSuffix("." + exactLower) ||
               nameLower.contains(".\(exactLower).") {
                return true
            }
        }
        
        for prefix in prefix {
            if nameLower.hasPrefix(prefix.lowercased()) {
                return true
            }
        }
        
        for term in contains where term.count >= 3 {
            if nameLower.contains(term.lowercased()) {
                return true
            }
        }
        
        return false
    }
    
    func matchesStrict(_ name: String) -> Bool {
        let nameLower = name.lowercased()
        
        for exact in exact {
            let exactLower = exact.lowercased()
            if nameLower == exactLower ||
               nameLower.hasPrefix(exactLower + ".") ||
               nameLower.contains(exactLower) {
                return true
            }
        }
        
        for prefix in prefix {
            if nameLower.hasPrefix(prefix.lowercased()) {
                return true
            }
        }
        
        return false
    }
}

struct UninstallItem: Identifiable {
    let id = UUID()
    let url: URL
    let displayName: String
    let kind: UninstallItemKind
    let note: String
    var sizeBytes: Int64?
    var isSelected: Bool
}

/// Scans for leftover files related to an app under ~/Library and prepares uninstall items.
final class UninstallerManager {
    private let fileManager = FileManager.default
    private let homeLibrary: URL
    private let systemLibrary: URL
    private let home: URL

    /// Sistem seviyesi konumlari da taramak icin true yap (/Library/)
    var includeSystemLocations: Bool = false
    /// WebKit / Developer / Frameworks vb. geniş tarama konumlarını dahil etmek için
    var includeAggressiveLocations: Bool = false

    init() {
        home = fileManager.homeDirectoryForCurrentUser
        homeLibrary = home.appendingPathComponent("Library")
        systemLibrary = URL(fileURLWithPath: "/Library")
    }

    func buildItems(appURL: URL, bundleId: String?, appName: String) -> [UninstallItem] {
        buildItemsDeep(appURL: appURL, bundleId: bundleId, appName: appName)
    }

    func buildItemsFast(appURL: URL, bundleId: String?, appName: String) -> [UninstallItem] {
        var items: [UninstallItem] = []
        var seenPaths: Set<String> = []

        if let appItem = makeAppBundleItem(appURL: appURL, computeSize: false) {
            items.append(appItem)
            seenPaths.insert(appURL.path)
        }

        let fastCandidates = findFastCandidates(bundleId: bundleId, appName: appName)
        for candidate in fastCandidates {
            let path = candidate.url.path
            guard !seenPaths.contains(path) else { continue }
            seenPaths.insert(path)

            if let item = buildItem(for: candidate, computeSize: false) {
                items.append(item)
            }
        }

        return sortItems(items)
    }

    func buildItemsDeep(appURL: URL, bundleId: String?, appName: String) -> [UninstallItem] {
        var items: [UninstallItem] = []
        var seenPaths: Set<String> = []

        if let appItem = makeAppBundleItem(appURL: appURL, computeSize: false) {
            items.append(appItem)
            seenPaths.insert(appURL.path)
        }

        let searchTerms = buildSearchTerms(bundleId: bundleId, appName: appName, appURL: appURL)
        let candidates = findAllCandidates(searchTerms: searchTerms, bundleId: bundleId, appName: appName, appURL: appURL)

        for candidate in candidates {
            let path = candidate.url.path
            guard !seenPaths.contains(path) else { continue }
            seenPaths.insert(path)

            if let item = buildItem(for: candidate, computeSize: false) {
                items.append(item)
            }
        }

        return sortItems(items)
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

    private func sortItems(_ items: [UninstallItem]) -> [UninstallItem] {
        items.sorted {
            let a = kindRank($0.kind), b = kindRank($1.kind)
            if a != b { return a < b }
            return $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        }
    }

    // MARK: - Search Terms

    private func buildSearchTerms(bundleId: String?, appName: String, appURL: URL) -> SearchTerms {
        var exactTerms: [String] = []
        var prefixTerms: [String] = []
        var containsTerms: [String] = []
        
        if let bundleId = bundleId {
            exactTerms.append(bundleId)
            
            let parts = bundleId.split(separator: ".")
            if parts.count >= 2 {
                let prefix = parts.prefix(2).joined(separator: ".")
                prefixTerms.append(prefix)
                
                if let company = parts.dropFirst().first {
                    containsTerms.append(String(company))
                }
                if let appPart = parts.last {
                    containsTerms.append(String(appPart))
                }
            }
            
            // Helper app patterns
            let helperSuffixes = [".helper", ".Helper", ".agent", ".Agent", ".updater", ".Updater",
                                 ".Launcher", ".launcher", ".CrashHandler", ".InstallHelper",
                                 ".LoginHelper", ".ServiceHelper", ".xpc"]
            for suffix in helperSuffixes {
                exactTerms.append(bundleId + suffix)
            }
        }
        
        containsTerms.append(appName)
        containsTerms.append(appName.replacingOccurrences(of: " ", with: ""))
        containsTerms.append(appName.replacingOccurrences(of: " ", with: "-"))
        containsTerms.append(appName.replacingOccurrences(of: " ", with: "_"))
        
        if let executableName = getExecutableName(from: appURL), executableName != appName {
            containsTerms.append(executableName)
        }
        
        let fileNameWithoutExt = appURL.deletingPathExtension().lastPathComponent
        if fileNameWithoutExt != appName {
            containsTerms.append(fileNameWithoutExt)
        }
        
        if let developerName = getDeveloperName(from: appURL) {
            containsTerms.append(developerName)
        }
        
        let lowercaseContains = containsTerms.map { $0.lowercased() }
        
        return SearchTerms(
            exact: Array(Set(exactTerms)).filter { !$0.isEmpty },
            prefix: Array(Set(prefixTerms)).filter { !$0.isEmpty },
            contains: Array(Set(containsTerms + lowercaseContains)).filter { !$0.isEmpty && $0.count > 2 }
        )
    }

    // MARK: - Candidate Finding

    private struct Candidate {
        let url: URL
        let kind: UninstallItemKind
        let note: String
    }

    private func findFastCandidates(bundleId: String?, appName: String) -> [Candidate] {
        var results: [Candidate] = []
        let lib = homeLibrary

        func addIfExists(_ url: URL, kind: UninstallItemKind, note: String) {
            guard fileManager.fileExists(atPath: url.path) else { return }
            results.append(Candidate(url: url, kind: kind, note: note))
        }

        guard let bundleId, !bundleId.isEmpty else { return results }

        addIfExists(lib.appendingPathComponent("Preferences").appendingPathComponent("\(bundleId).plist"),
                    kind: .preferences,
                    note: "Fast: Preferences")

        addIfExists(lib.appendingPathComponent("Saved Application State").appendingPathComponent("\(bundleId).savedState"),
                    kind: .savedState,
                    note: "Fast: Saved State")

        addIfExists(lib.appendingPathComponent("Containers").appendingPathComponent(bundleId),
                    kind: .containers,
                    note: "Fast: Containers")

        addIfExists(lib.appendingPathComponent("Application Support").appendingPathComponent(bundleId),
                    kind: .applicationSupport,
                    note: "Fast: App Support (bundleId)")
        addIfExists(lib.appendingPathComponent("Application Support").appendingPathComponent(appName),
                    kind: .applicationSupport,
                    note: "Fast: App Support (appName)")

        addIfExists(lib.appendingPathComponent("Caches").appendingPathComponent(bundleId),
                    kind: .caches,
                    note: "Fast: Caches (bundleId)")
        addIfExists(lib.appendingPathComponent("Caches").appendingPathComponent(appName),
                    kind: .caches,
                    note: "Fast: Caches (appName)")

        addIfExists(lib.appendingPathComponent("Logs").appendingPathComponent(bundleId),
                    kind: .logs,
                    note: "Fast: Logs (bundleId)")
        addIfExists(lib.appendingPathComponent("Logs").appendingPathComponent(appName),
                    kind: .logs,
                    note: "Fast: Logs (appName)")

        let byHost = lib.appendingPathComponent("Preferences/ByHost")
        if let urls = try? fileManager.contentsOfDirectory(at: byHost, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
            for url in urls where url.lastPathComponent.hasPrefix(bundleId) {
                results.append(Candidate(url: url, kind: .preferencesByHost, note: "Fast: ByHost"))
            }
        }

        let group = lib.appendingPathComponent("Group Containers")
        if let urls = try? fileManager.contentsOfDirectory(at: group, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
            for url in urls {
                let name = url.lastPathComponent
                if name.contains(bundleId) || name.contains("group.\(bundleId)") {
                    results.append(Candidate(url: url, kind: .groupContainers, note: "Fast: Group Containers"))
                }
            }
        }

        let launchAgents = lib.appendingPathComponent("LaunchAgents")
        if let urls = try? fileManager.contentsOfDirectory(at: launchAgents, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
            for url in urls where url.lastPathComponent.contains(bundleId) {
                results.append(Candidate(url: url, kind: .launchAgents, note: "Fast: LaunchAgents"))
            }
        }

        return results
    }

    private func findAllCandidates(searchTerms: SearchTerms, bundleId: String?, appName: String, appURL: URL) -> [Candidate] {
        var candidates: [Candidate] = []
        
        let baseLocations: [(String, UninstallItemKind, Bool)] = [
            ("Application Support", .applicationSupport, true),
            ("Caches", .caches, true),
            ("Preferences", .preferences, false),
            ("Logs", .logs, true),
            ("Saved Application State", .savedState, false),
            ("Containers", .containers, false),
            ("Group Containers", .groupContainers, true),
            ("LaunchAgents", .launchAgents, false),
            ("HTTPStorages", .httpStorages, false),
            ("Cookies", .cookies, false),
            ("Application Scripts", .applicationScripts, false),
            ("Caches/com.apple.nsurlsessiond/Downloads", .caches, true),
        ]

        let aggressiveLocations: [(String, UninstallItemKind, Bool)] = [
            ("WebKit", .webKit, true),
            ("Internet Plug-Ins", .internetPlugins, false),
            ("PreferencePanes", .preferencePanes, false),
            ("QuickLook", .quickLook, false),
            ("Screen Savers", .screenSavers, false),
            ("Services", .services, false),
            ("Spotlight", .spotlight, false),
            ("Input Methods", .inputMethods, false),
            ("Frameworks", .frameworks, true),
            ("ColorPickers", .colorPickers, false),
            ("Address Book Plug-Ins", .addressBookPlugins, false),
            ("Mail/Bundles", .mailBundles, false),
            ("Developer", .developer, true),
            ("Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments", .recentDocuments, false),
        ]

        let searchLocations = baseLocations + (includeAggressiveLocations ? aggressiveLocations : [])
        
        for (subpath, kind, recursive) in searchLocations {
            let dirURL = homeLibrary.appendingPathComponent(subpath)
            guard fileManager.fileExists(atPath: dirURL.path) else { continue }
            
            let found = searchDirectory(
                at: dirURL,
                searchTerms: searchTerms,
                kind: kind,
                recursive: recursive,
                maxDepth: recursive ?3 : 1
            )
            candidates.append(contentsOf: found)
        }
        
        // Preferences/ByHost ozel arama
        let byHostCandidates = searchByHost(searchTerms: searchTerms)
        candidates.append(contentsOf: byHostCandidates)

        // Crash Reports
        let crashCandidates = searchCrashReports(searchTerms: searchTerms)
        candidates.append(contentsOf: crashCandidates)

        // Embedded helper app'lerin kalıntılarını ara
        let helperCandidates = findEmbeddedHelperApps(appURL: appURL, baseTerms: searchTerms)
        candidates.append(contentsOf: helperCandidates)
        
        // Installer receipts
        let receiptCandidates = searchInstallerReceipts(searchTerms: searchTerms, bundleId: bundleId)
        candidates.append(contentsOf: receiptCandidates)

        // Sistem seviyesi konumlar (sadece includeSystemLocations true ise)
        if includeSystemLocations {
            let systemCandidates = searchSystemLocations(searchTerms: searchTerms)
            candidates.append(contentsOf: systemCandidates)
        }

        return candidates
    }

    private func searchDirectory(
        at url: URL,
        searchTerms: SearchTerms,
        kind: UninstallItemKind,
        recursive: Bool,
        maxDepth: Int,
        currentDepth: Int = 0
    ) -> [Candidate] {
        var results: [Candidate] = []
        
        guard currentDepth < maxDepth else { return results }
        guard isInsideHomeLibrary(url) else { return results }
        
        guard let contents = try? fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey],
            options: [.skipsHiddenFiles]
        ) else { return results }
        
        for itemURL in contents {
            // Symlink atla
            if isSymlink(itemURL) { continue }
            
            let itemName = itemURL.lastPathComponent
            let itemNameLower = itemName.lowercased()
            
            // Eşleşme kontrolü
            let matches = searchTerms.matches(itemName)
            
            if matches {
                results.append(Candidate(
                    url: itemURL,
                    kind: kind,
                    note: url.lastPathComponent
                ))
            } else if recursive {
                // Alt klasörleri tara
                let isDir = (try? itemURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                if isDir {
                    let subResults = searchDirectory(
                        at: itemURL,
                        searchTerms: searchTerms,
                        kind: kind,
                        recursive: true,
                        maxDepth: maxDepth,
                        currentDepth: currentDepth + 1
                    )
                    results.append(contentsOf: subResults)
                }
            }
        }
        
        return results
    }

    private func searchByHost(searchTerms: SearchTerms) -> [Candidate] {
        let byHostDir = homeLibrary.appendingPathComponent("Preferences/ByHost")
        guard let contents = try? fileManager.contentsOfDirectory(
            at: byHostDir,
            includingPropertiesForKeys: [.isSymbolicLinkKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        
        return contents.compactMap { url -> Candidate? in
            guard !isSymlink(url) else { return nil }
            let name = url.lastPathComponent.lowercased()
            let matches = searchTerms.matches(name)
            guard matches else { return nil }
            
            return Candidate(
                url: url,
                kind: .preferencesByHost,
                note: "Preferences/ByHost"
            )
        }
    }

    private func searchCrashReports(searchTerms: SearchTerms) -> [Candidate] {
        var results: [Candidate] = []
        
        let crashDirs = [
            homeLibrary.appendingPathComponent("Logs/DiagnosticReports"),
            homeLibrary.appendingPathComponent("Logs/CrashReporter")
        ]
        
        for crashDir in crashDirs {
            guard let contents = try? fileManager.contentsOfDirectory(
                at: crashDir,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else { continue }
            
            for url in contents {
                let name = url.lastPathComponent.lowercased()
                let matches = searchTerms.matches(name)
                if matches {
                    results.append(Candidate(
                        url: url,
                        kind: .crashReports,
                        note: crashDir.lastPathComponent
                    ))
                }
            }
        }
        
        return results
    }

    // MARK: - System Locations Search

    /// /Library/ altindaki sistem seviyesi konumlari tarar
    /// Guvenlik: /System/, /usr/, /bin/, /sbin/, /private/ (receipts haric) ASLA taranmaz
    private func searchSystemLocations(searchTerms: SearchTerms) -> [Candidate] {
        var results: [Candidate] = []

        // Sistem seviyesi konumlar (/Library/ altinda)
        let systemLocations: [(String, UninstallItemKind, Bool)] = [
            ("Application Support", .systemAppSupport, true),
            ("LaunchAgents", .systemLaunchAgents, false),
            ("LaunchDaemons", .systemLaunchDaemons, false),
            ("PrivilegedHelperTools", .privilegedHelpers, false),
            ("Preferences", .systemPreferences, false),
            ("Frameworks", .systemFrameworks, true),
        ]

        for (subpath, kind, recursive) in systemLocations {
            let dirURL = systemLibrary.appendingPathComponent(subpath)
            guard fileManager.fileExists(atPath: dirURL.path) else { continue }

            let found = searchSystemDirectory(
                at: dirURL,
                searchTerms: searchTerms,
                kind: kind,
                recursive: recursive,
                maxDepth: recursive ? 2 : 1
            )
            results.append(contentsOf: found)
        }

        return results
    }

    /// Sistem dizinlerini tarar - homeLibrary yerine systemLibrary kontrolu yapar
    private func searchSystemDirectory(
        at url: URL,
        searchTerms: SearchTerms,
        kind: UninstallItemKind,
        recursive: Bool,
        maxDepth: Int,
        currentDepth: Int = 0
    ) -> [Candidate] {
        var results: [Candidate] = []

        guard currentDepth < maxDepth else { return results }

        // Guvenlik kontrolleri - bu konumlari ASLA tarama
        let path = url.path
        let forbiddenPrefixes = ["/System", "/usr", "/bin", "/sbin", "/private"]

        // Eger path yasakli bir prefix ile basliyorsa atla
        for forbidden in forbiddenPrefixes {
            if path.hasPrefix(forbidden) {
                return results
            }
        }

        // Sadece /Library altini tara (tek izinli konum)
        guard path.hasPrefix("/Library") else { return results }

        guard let contents = try? fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey],
            options: [.skipsHiddenFiles]
        ) else { return results }

        for itemURL in contents {
            // Symlink atla
            if isSymlink(itemURL) { continue }

            let itemName = itemURL.lastPathComponent
            let itemNameLower = itemName.lowercased()

            // Eslesme kontrolu
            let matches = searchTerms.matchesStrict(itemName)

            if matches {
                results.append(Candidate(
                    url: itemURL,
                    kind: kind,
                    note: "/Library/\(url.lastPathComponent)"
                ))
            } else if recursive {
                // Alt klasorleri tara
                let isDir = (try? itemURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                if isDir {
                    let subResults = searchSystemDirectory(
                        at: itemURL,
                        searchTerms: searchTerms,
                        kind: kind,
                        recursive: true,
                        maxDepth: maxDepth,
                        currentDepth: currentDepth + 1
                    )
                    results.append(contentsOf: subResults)
                }
            }
        }

        return results
    }

    // MARK: - Item Building

    private func makeAppBundleItem(appURL: URL, computeSize: Bool) -> UninstallItem? {
        if isSymlink(appURL) { return nil }

        let size = computeSize ? sizeOfItem(at: appURL, allowOutsideHome: true) : nil
        return UninstallItem(
            url: appURL,
            displayName: appURL.lastPathComponent,
            kind: .appBundle,
            note: "Uygulama Paketi",
            sizeBytes: size,
            isSelected: true
        )
    }

    private func buildItem(for candidate: Candidate, computeSize: Bool) -> UninstallItem? {
        // Hem ~/Library hem de /Library izinli
        let isValidLocation = isInsideHomeLibrary(candidate.url) || isInsideSystemLibrary(candidate.url)
        guard isValidLocation else { return nil }
        guard fileManager.fileExists(atPath: candidate.url.path) else { return nil }
        guard !isSymlink(candidate.url) else { return nil }

        // Sistem dosyalari icin allowOutsideHome true olmali
        let isSystemFile = isInsideSystemLibrary(candidate.url)
        let size = computeSize ? sizeOfItem(at: candidate.url, allowOutsideHome: isSystemFile) : nil
        return UninstallItem(
            url: candidate.url,
            displayName: candidate.url.lastPathComponent,
            kind: candidate.kind,
            note: candidate.note,
            sizeBytes: size,
            isSelected: true
        )
    }

    // MARK: - Size Calculation

    func computeSizeBytes(for url: URL) -> Int64? {
        let isSystem = isInsideSystemLibrary(url)
        return sizeOfItem(at: url, allowOutsideHome: isSystem)
    }

    private func sizeOfItem(at url: URL, allowOutsideHome: Bool) -> Int64? {
        let standardized = url.standardizedFileURL
        if !allowOutsideHome && !standardized.path.hasPrefix(home.path) {
            return nil
        }

        let keys: Set<URLResourceKey> = [
            .isDirectoryKey,
            .isSymbolicLinkKey,
            .totalFileAllocatedSizeKey,
            .fileAllocatedSizeKey,
            .totalFileSizeKey,
            .fileSizeKey
        ]

        guard let values = try? standardized.resourceValues(forKeys: keys) else { return nil }
        if values.isSymbolicLink == true { return nil }

        if values.isDirectory == true {
            return sizeOfDirectory(at: standardized, keys: keys)
        } else {
            return fileSize(from: values)
        }
    }

    private func sizeOfDirectory(at url: URL, keys: Set<URLResourceKey>) -> Int64 {
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: Array(keys),
            options: [],
            errorHandler: nil
        ) else { return 0 }

        var total: Int64 = 0

        for case let fileURL as URL in enumerator {
            // Symlink kontrolü
            if isSymlink(fileURL) {
                enumerator.skipDescendants()
                continue
            }

            guard let values = try? fileURL.resourceValues(forKeys: keys) else { continue }
            
            // Sadece dosyaları say
            if values.isDirectory == true { continue }
            
            total += fileSize(from: values)
        }

        return total
    }

    private func fileSize(from values: URLResourceValues) -> Int64 {
        // Allocated size daha doğru (disk üzerindeki gerçek boyut)
        if let allocated = values.totalFileAllocatedSize, allocated > 0 {
            return Int64(allocated)
        }
        if let allocated = values.fileAllocatedSize, allocated > 0 {
            return Int64(allocated)
        }
        // Fallback: logical size
        if let size = values.totalFileSize {
            return Int64(size)
        }
        if let size = values.fileSize {
            return Int64(size)
        }
        return 0
    }

    // MARK: - Helpers

    private func isInsideHomeLibrary(_ url: URL) -> Bool {
        url.standardizedFileURL.path.hasPrefix(homeLibrary.path)
    }

    private func isInsideSystemLibrary(_ url: URL) -> Bool {
        let path = url.standardizedFileURL.path
        // Sadece /Library/ altini kabul et, /System/Library/ vs. degil
        return path.hasPrefix("/Library/") && !path.hasPrefix("/Library/Apple")
    }

    private func isSymlink(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) ?? false
    }

    // MARK: - Info.plist Helpers

    private func getExecutableName(from appURL: URL) -> String? {
        let plistURL = appURL.appendingPathComponent("Contents/Info.plist")
        guard let plistData = try? Data(contentsOf: plistURL),
              let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else {
            return nil
        }
        return plist["CFBundleExecutable"] as? String
    }

    private func getDeveloperName(from appURL: URL) -> String? {
        let plistURL = appURL.appendingPathComponent("Contents/Info.plist")
        guard let plistData = try? Data(contentsOf: plistURL),
              let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else {
            return nil
        }
        
        if let copyright = plist["NSHumanReadableCopyright"] as? String {
            return extractCompanyName(from: copyright)
        }
        return nil
    }

    private func extractCompanyName(from copyright: String) -> String? {
        let patterns = [
            "©\\s*\\d{4}\\s+([A-Za-z][A-Za-z0-9\\s]+?)(?:\\.|,|All|Inc|LLC|Ltd|Corp|$)",
            "Copyright\\s*(?:©)?\\s*\\d{4}\\s+([A-Za-z][A-Za-z0-9\\s]+?)(?:\\.|,|All|Inc|LLC|Ltd|Corp|$)",
            "by\\s+([A-Za-z][A-Za-z0-9\\s]+?)(?:\\.|,|$)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: copyright, range: NSRange(copyright.startIndex..., in: copyright)),
               let range = Range(match.range(at: 1), in: copyright) {
                let name = String(copyright[range])
                    .trimmingCharacters(in: .whitespaces)
                    .components(separatedBy: .whitespaces)
                    .first ?? ""
                if !name.isEmpty && name.count > 2 {
                    return name
                }
            }
        }
        return nil
    }

    // MARK: - Embedded Helper Apps

    private func findEmbeddedHelperApps(appURL: URL, baseTerms: SearchTerms) -> [Candidate] {
        var results: [Candidate] = []
        
        let helperPaths = [
            "Contents/Library/LoginItems",
            "Contents/Library/LaunchServices",
            "Contents/Helpers",
            "Contents/XPCServices"
        ]
        
        for helperPath in helperPaths {
            let helperDir = appURL.appendingPathComponent(helperPath)
            guard fileManager.fileExists(atPath: helperDir.path) else { continue }
            
            guard let contents = try? fileManager.contentsOfDirectory(
                at: helperDir,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else { continue }
            
            for itemURL in contents {
                let ext = itemURL.pathExtension.lowercased()
                guard ext == "app" || ext == "xpc" else { continue }
                
                if let helperBundle = Bundle(url: itemURL),
                   let helperBundleId = helperBundle.bundleIdentifier {
                    let helperTerms = buildSearchTerms(
                        bundleId: helperBundleId,
                        appName: itemURL.deletingPathExtension().lastPathComponent,
                        appURL: itemURL
                    )
                    let launchResults = searchLaunchItemsForHelper(searchTerms: helperTerms)
                    results.append(contentsOf: launchResults)
                }
            }
        }
        
        return results
    }

    private func searchLaunchItemsForHelper(searchTerms: SearchTerms) -> [Candidate] {
        var results: [Candidate] = []
        
        var launchDirs: [(URL, UninstallItemKind)] = [
            (homeLibrary.appendingPathComponent("LaunchAgents"), .launchAgents),
        ]
        
        if includeSystemLocations {
            launchDirs.append((URL(fileURLWithPath: "/Library/LaunchAgents"), .systemLaunchAgents))
            launchDirs.append((URL(fileURLWithPath: "/Library/LaunchDaemons"), .systemLaunchDaemons))
        }
        
        for (dirURL, kind) in launchDirs {
            guard fileManager.fileExists(atPath: dirURL.path) else { continue }
            
            guard let contents = try? fileManager.contentsOfDirectory(
                at: dirURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else { continue }
            
            for plistURL in contents where plistURL.pathExtension == "plist" {
                let name = plistURL.deletingPathExtension().lastPathComponent
                if searchTerms.matchesStrict(name) {
                    results.append(Candidate(
                        url: plistURL,
                        kind: kind,
                        note: "Helper: \(dirURL.lastPathComponent)"
                    ))
                }
            }
        }
        
        return results
    }

    // MARK: - Installer Receipts

// MARK: - Installer Receipts

    private func searchInstallerReceipts(searchTerms: SearchTerms, bundleId: String?) -> [Candidate] {
        guard includeSystemLocations else { return [] }
        
        var results: [Candidate] = []
        let receiptsDir = URL(fileURLWithPath: "/private/var/db/receipts")
        
        guard fileManager.fileExists(atPath: receiptsDir.path) else { return results }
        
        guard let contents = try? fileManager.contentsOfDirectory(
            at: receiptsDir,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return results }
        
        for url in contents {
            let ext = url.pathExtension.lowercased()
            guard ext == "bom" || ext == "plist" else { continue }
            
            let receiptBase = url.deletingPathExtension().lastPathComponent
            var matches = false
            
            if let bundleId = bundleId {
                let bundleLower = bundleId.lowercased()
                let baseLower = receiptBase.lowercased()
                if baseLower == bundleLower || baseLower.hasPrefix(bundleLower) {
                    matches = true
                }
            }
            
            if !matches {
                matches = searchTerms.matchesStrict(receiptBase)
            }
            
            if matches {
                results.append(Candidate(
                    url: url,
                    kind: .other,
                    note: "Installer Receipt"
                ))
            }
        }
        
        return results
    }
}
