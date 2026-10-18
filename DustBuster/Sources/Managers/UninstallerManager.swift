// Sources/Managers/UninstallerManager.swift

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
    // Ek kullanıcı konumları
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
    case other = "Diğer"
}

// MARK: - Eşleştirme

/// Bir kalıntının uygulamaya ne kadar güvenle bağlandığı.
enum UninstallMatchStrength {
    /// Bundle ID eşleşmesi veya uygulama adıyla birebir aynı ad → varsayılan seçili
    case strong
    /// Uygulama adı, daha uzun bir adın parçası olarak geçiyor → kullanıcı kontrol etsin, seçimsiz
    case weak
}

/// Arama kriterleri. Yalnızca iki şey eşleşir:
///  1) Bundle ID (tam, alt paket, grup veya takım-ID önekli biçimleri)
///  2) Uygulama adı — kelime sınırıyla (alt dize araması yapılmaz)
/// Geliştirici öneki (`ai.storyteller`), bundle ID'nin son parçası (`app`) veya telif
/// hakkındaki şirket adı gibi aynı geliştiricinin BAŞKA uygulamalarını da yakalayan
/// terimler bilinçli olarak kullanılmaz.
struct SearchTerms {
    /// Küçük harfli bundle ID'ler (ana uygulama; yardımcılar ayrı tutulur)
    let bundleIds: [String]
    /// Uygulama adı varyantları, küçük harfli ve token'lara ayrılmış
    let nameTokenSets: [[String]]
    /// Uygulama Apple'ın mı? Değilse `com.apple.*` adları asla eşleşmez.
    let isAppleApp: Bool

    static let minNameLength = 4

    /// Tek başına bir uygulamayı tanımlamayan, çok sayıda yanlış eşleşme üreten adlar.
    static let genericNames: Set<String> = [
        "app", "apps", "application", "helper", "helpers", "launcher", "agent", "daemon",
        "update", "updater", "updates", "installer", "install", "uninstaller", "setup",
        "client", "server", "service", "services", "mac", "macos", "osx", "apple",
        "system", "library", "tool", "tools", "utility", "utilities", "manager",
        "player", "viewer", "reader", "editor", "browser", "chat", "mail", "music",
        "photos", "photo", "video", "notes", "finder", "safari", "preview", "calendar",
        "terminal", "console", "settings", "preferences", "support", "cache", "caches",
        "logs", "log", "data", "default", "test", "demo", "beta", "alpha", "pro", "lite",
        "free", "plus", "studio", "office", "home", "cloud", "sync", "drive", "backup",
        "menu", "bar", "widget", "dock", "launch", "login", "core", "base", "main",
        "new", "old", "temp", "tmp", "user", "users", "shared", "common", "google",
        "microsoft", "adobe", "mozilla", "chrome", "firefox", "edge", "opera"
    ]

    static func tokens(of text: String) -> [String] {
        text.lowercased()
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .map(String.init)
    }

    /// Uygulama adı ve varyantlarından token kümeleri üretir; genel/kısa adları eler.
    static func makeNameTokenSets(appName: String, extraNames: [String]) -> [[String]] {
        var sets: [[String]] = []
        for raw in [appName] + extraNames {
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.count >= minNameLength else { continue }
            let toks = tokens(of: trimmed)
            guard !toks.isEmpty else { continue }
            let squashed = toks.joined()
            guard squashed.count >= minNameLength else { continue }
            guard !genericNames.contains(squashed) else { continue }
            guard squashed.rangeOfCharacter(from: .letters) != nil else { continue }
            if !sets.contains(toks) { sets.append(toks) }
            if toks.count > 1 && !sets.contains([squashed]) { sets.append([squashed]) }
        }
        return sets
    }

    static func containsContiguous(_ needle: [String], in haystack: [String]) -> Bool {
        guard !needle.isEmpty, needle.count <= haystack.count else { return false }
        let last = haystack.count - needle.count
        for start in 0...last where Array(haystack[start..<(start + needle.count)]) == needle {
            return true
        }
        return false
    }

    func matchesBundleId(_ name: String) -> Bool {
        let n = name.lowercased()
        for bid in bundleIds {
            if n == bid
                || n.hasPrefix(bid + ".")
                || n.hasSuffix("." + bid)
                || n.contains("." + bid + ".") {
                return true
            }
        }
        return false
    }

    /// Verilen dosya/klasör adının uygulamaya ait olup olmadığını ve eşleşme gücünü döner.
    func match(_ rawName: String, isDirectory: Bool = false) -> UninstallMatchStrength? {
        let name = rawName.lowercased()

        // Apple'a ait adlar: kaldırılan uygulama Apple'ın değilse asla eşleşmez
        if !isAppleApp && (name == "com.apple" || name.hasPrefix("com.apple.")) {
            return nil
        }

        if matchesBundleId(name) {
            return .strong
        }

        guard !nameTokenSets.isEmpty else { return nil }

        let fullTokens = SearchTerms.tokens(of: name)
        guard !fullTokens.isEmpty else { return nil }

        // Dosya ise uzantıyı at ("PdfCraft.log" → "pdfcraft")
        var baseTokens = fullTokens
        if !isDirectory, let dot = name.lastIndex(of: "."), dot != name.startIndex {
            baseTokens = SearchTerms.tokens(of: String(name[..<dot]))
        }

        for termTokens in nameTokenSets where baseTokens == termTokens || fullTokens == termTokens {
            return .strong
        }
        for termTokens in nameTokenSets where SearchTerms.containsContiguous(termTokens, in: fullTokens) {
            return .weak
        }
        return nil
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
    /// false ise yalnızca ad benzerliğiyle bulunmuştur; UI bunu etiketler ve seçimsiz gösterir
    let isStrongMatch: Bool
}

/// Scans for leftover files related to an app under ~/Library and prepares uninstall items.
final class UninstallerManager {
    /// Bu sayının üzerinde sonuç dönerse tarama "patlamış" kabul edilir; liste gösterilmez.
    static let maxReasonableResults = 100

    private let fileManager = FileManager.default
    private let homeLibrary: URL
    private let systemLibrary: URL
    private let home: URL

    /// Sistem seviyesi konumları da taramak için true yap (/Library/)
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

    /// Yalnızca bundle ID / tam ad ile birebir bilinen yolları kontrol eder (hızlı, kesin).
    func buildItemsFast(appURL: URL, bundleId: String?, appName: String) -> [UninstallItem] {
        var items: [UninstallItem] = []
        var seenPaths: Set<String> = []

        if let appItem = makeAppBundleItem(appURL: appURL) {
            items.append(appItem)
            seenPaths.insert(appURL.path)
        }

        let terms = buildSearchTerms(bundleId: bundleId, appName: appName, appURL: appURL)
        let fastCandidates = findFastCandidates(terms: terms, bundleId: bundleId, appName: appName)
        for candidate in fastCandidates {
            let path = candidate.url.path
            guard !seenPaths.contains(path) else { continue }
            seenPaths.insert(path)

            if let item = buildItem(for: candidate) {
                items.append(item)
            }
        }

        return sortItems(items)
    }

    /// ~/Library altındaki konumları tarar; eşleşme gücüne göre seçili/seçimsiz öğeler üretir.
    func buildItemsDeep(appURL: URL, bundleId: String?, appName: String) -> [UninstallItem] {
        var items: [UninstallItem] = []
        var seenPaths: Set<String> = []

        if let appItem = makeAppBundleItem(appURL: appURL) {
            items.append(appItem)
            seenPaths.insert(appURL.path)
        }

        let searchTerms = buildSearchTerms(bundleId: bundleId, appName: appName, appURL: appURL)
        let candidates = findAllCandidates(searchTerms: searchTerms, bundleId: bundleId, appURL: appURL)

        for candidate in candidates {
            let path = candidate.url.path
            guard !seenPaths.contains(path) else { continue }
            seenPaths.insert(path)

            if let item = buildItem(for: candidate) {
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
            if $0.isStrongMatch != $1.isStrongMatch { return $0.isStrongMatch }
            let a = kindRank($0.kind), b = kindRank($1.kind)
            if a != b { return a < b }
            return $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        }
    }

    // MARK: - Search Terms

    private func buildSearchTerms(bundleId: String?, appName: String, appURL: URL) -> SearchTerms {
        var bundleIds: [String] = []
        if let bid = bundleId?.lowercased(), !bid.isEmpty {
            bundleIds.append(bid)
        }

        var extraNames: [String] = []
        if let executableName = getExecutableName(from: appURL), executableName != appName {
            extraNames.append(executableName)
        }
        let fileNameWithoutExt = appURL.deletingPathExtension().lastPathComponent
        if fileNameWithoutExt != appName {
            extraNames.append(fileNameWithoutExt)
        }

        let isApple = bundleId?.lowercased().hasPrefix("com.apple.") ?? false

        return SearchTerms(
            bundleIds: bundleIds,
            nameTokenSets: SearchTerms.makeNameTokenSets(appName: appName, extraNames: extraNames),
            isAppleApp: isApple
        )
    }

    // MARK: - Candidate Finding

    private struct Candidate {
        let url: URL
        let kind: UninstallItemKind
        let note: String
        let strength: UninstallMatchStrength
    }

    private func findFastCandidates(terms: SearchTerms, bundleId: String?, appName: String) -> [Candidate] {
        var results: [Candidate] = []
        let lib = homeLibrary

        func addIfExists(_ url: URL, kind: UninstallItemKind, note: String) {
            guard fileManager.fileExists(atPath: url.path) else { return }
            results.append(Candidate(url: url, kind: kind, note: note, strength: .strong))
        }

        guard let bundleId, !bundleId.isEmpty else { return results }

        // Uygulama adı genel/kısa ise ("Reader", "App") ad bazlı yollar kullanılmaz
        let useAppName = !terms.nameTokenSets.isEmpty

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
        if useAppName {
            addIfExists(lib.appendingPathComponent("Application Support").appendingPathComponent(appName),
                        kind: .applicationSupport,
                        note: "Fast: App Support (appName)")
        }

        addIfExists(lib.appendingPathComponent("Caches").appendingPathComponent(bundleId),
                    kind: .caches,
                    note: "Fast: Caches (bundleId)")
        if useAppName {
            addIfExists(lib.appendingPathComponent("Caches").appendingPathComponent(appName),
                        kind: .caches,
                        note: "Fast: Caches (appName)")
        }

        addIfExists(lib.appendingPathComponent("Logs").appendingPathComponent(bundleId),
                    kind: .logs,
                    note: "Fast: Logs (bundleId)")
        if useAppName {
            addIfExists(lib.appendingPathComponent("Logs").appendingPathComponent(appName),
                        kind: .logs,
                        note: "Fast: Logs (appName)")
        }

        addIfExists(lib.appendingPathComponent("HTTPStorages").appendingPathComponent(bundleId),
                    kind: .httpStorages,
                    note: "Fast: HTTPStorages")

        addIfExists(lib.appendingPathComponent("WebKit").appendingPathComponent(bundleId),
                    kind: .webKit,
                    note: "Fast: WebKit")

        let byHost = lib.appendingPathComponent("Preferences/ByHost")
        if let urls = try? fileManager.contentsOfDirectory(at: byHost, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
            for url in urls where terms.matchesBundleId(url.lastPathComponent) {
                results.append(Candidate(url: url, kind: .preferencesByHost, note: "Fast: ByHost", strength: .strong))
            }
        }

        let group = lib.appendingPathComponent("Group Containers")
        if let urls = try? fileManager.contentsOfDirectory(at: group, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
            for url in urls where terms.matchesBundleId(url.lastPathComponent) {
                results.append(Candidate(url: url, kind: .groupContainers, note: "Fast: Group Containers", strength: .strong))
            }
        }

        let launchAgents = lib.appendingPathComponent("LaunchAgents")
        if let urls = try? fileManager.contentsOfDirectory(at: launchAgents, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
            for url in urls where terms.matchesBundleId(url.lastPathComponent) {
                results.append(Candidate(url: url, kind: .launchAgents, note: "Fast: LaunchAgents", strength: .strong))
            }
        }

        return results
    }

    private func findAllCandidates(searchTerms: SearchTerms, bundleId: String?, appURL: URL) -> [Candidate] {
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
                maxDepth: recursive ? 3 : 1
            )
            candidates.append(contentsOf: found)
        }

        // Preferences/ByHost özel arama
        candidates.append(contentsOf: searchByHost(searchTerms: searchTerms))

        // Crash Reports
        candidates.append(contentsOf: searchCrashReports(searchTerms: searchTerms))

        // Gömülü yardımcı uygulamaların launchd kalıntıları
        candidates.append(contentsOf: findEmbeddedHelperApps(appURL: appURL, baseTerms: searchTerms))

        // Installer receipts
        candidates.append(contentsOf: searchInstallerReceipts(searchTerms: searchTerms, bundleId: bundleId))

        // Sistem seviyesi konumlar (sadece includeSystemLocations true ise)
        if includeSystemLocations {
            candidates.append(contentsOf: searchSystemLocations(searchTerms: searchTerms))
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
            if isSymlink(itemURL) { continue }

            let itemName = itemURL.lastPathComponent
            let isDir = (try? itemURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false

            if let strength = searchTerms.match(itemName, isDirectory: isDir) {
                results.append(Candidate(
                    url: itemURL,
                    kind: kind,
                    note: url.lastPathComponent,
                    strength: strength
                ))
            } else if recursive && isDir {
                // Apple klasörlerinin içine inme (uygulama Apple'ın değilse)
                if !searchTerms.isAppleApp && itemName.lowercased().hasPrefix("com.apple.") { continue }

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
            guard let strength = searchTerms.match(url.lastPathComponent, isDirectory: false) else { return nil }
            return Candidate(
                url: url,
                kind: .preferencesByHost,
                note: "Preferences/ByHost",
                strength: strength
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
                guard let strength = searchTerms.match(url.lastPathComponent, isDirectory: false) else { continue }
                results.append(Candidate(
                    url: url,
                    kind: .crashReports,
                    note: crashDir.lastPathComponent,
                    strength: strength
                ))
            }
        }

        return results
    }

    // MARK: - System Locations Search

    /// /Library/ altındaki sistem seviyesi konumları tarar (yalnızca güçlü eşleşme).
    /// Güvenlik: /System/, /usr/, /bin/, /sbin/, /private/ (receipts hariç) ASLA taranmaz
    private func searchSystemLocations(searchTerms: SearchTerms) -> [Candidate] {
        var results: [Candidate] = []

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

        let path = url.path
        let forbiddenPrefixes = ["/System", "/usr", "/bin", "/sbin", "/private"]
        for forbidden in forbiddenPrefixes where path.hasPrefix(forbidden) {
            return results
        }

        guard path.hasPrefix("/Library") else { return results }

        guard let contents = try? fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey],
            options: [.skipsHiddenFiles]
        ) else { return results }

        for itemURL in contents {
            if isSymlink(itemURL) { continue }

            let itemName = itemURL.lastPathComponent
            let isDir = (try? itemURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false

            if searchTerms.match(itemName, isDirectory: isDir) == .strong {
                results.append(Candidate(
                    url: itemURL,
                    kind: kind,
                    note: "/Library/\(url.lastPathComponent)",
                    strength: .strong
                ))
            } else if recursive && isDir {
                if !searchTerms.isAppleApp && itemName.lowercased().hasPrefix("com.apple.") { continue }
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

        return results
    }

    // MARK: - Item Building

    private func makeAppBundleItem(appURL: URL) -> UninstallItem? {
        if isSymlink(appURL) { return nil }

        return UninstallItem(
            url: appURL,
            displayName: appURL.lastPathComponent,
            kind: .appBundle,
            note: "Uygulama Paketi",
            sizeBytes: nil,
            isSelected: true,
            isStrongMatch: true
        )
    }

    private func buildItem(for candidate: Candidate) -> UninstallItem? {
        let isValidLocation = isInsideHomeLibrary(candidate.url) || isInsideSystemLibrary(candidate.url)
        guard isValidLocation else { return nil }
        guard fileManager.fileExists(atPath: candidate.url.path) else { return nil }
        guard !isSymlink(candidate.url) else { return nil }

        let strong = candidate.strength == .strong
        return UninstallItem(
            url: candidate.url,
            displayName: candidate.url.lastPathComponent,
            kind: candidate.kind,
            note: candidate.note,
            sizeBytes: nil,
            isSelected: strong,
            isStrongMatch: strong
        )
    }

    // MARK: - Size Calculation

    /// Boyut hesabı. Home dışındaki yollar yalnızca uygulama paketi (/Applications/…app) veya
    /// /Library altı ise hesaplanır.
    func computeSizeBytes(for url: URL, isAppBundle: Bool = false) -> Int64? {
        let allowOutsideHome = isAppBundle || isInsideSystemLibrary(url)
        return sizeOfItem(at: url, allowOutsideHome: allowOutsideHome)
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
            if isSymlink(fileURL) {
                enumerator.skipDescendants()
                continue
            }

            guard let values = try? fileURL.resourceValues(forKeys: keys) else { continue }
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
        // Sadece /Library/ altını kabul et, /System/Library/ vs. değil
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

    // MARK: - Embedded Helper Apps

    /// Paketin içindeki yardımcı uygulamaların (LoginItems, XPC vb.) bundle ID'leriyle
    /// yalnızca launchd konumlarını tarar. Yardımcı ID'leri genel aramaya karıştırılmaz;
    /// Sparkle gibi paylaşılan çerçevelerin önbellekleri başka uygulamalara da ait olabilir.
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

                guard let helperBundle = Bundle(url: itemURL),
                      let helperBundleId = helperBundle.bundleIdentifier?.lowercased(),
                      !helperBundleId.isEmpty else { continue }

                // Apple veya tamamen ilgisiz görünen yardımcı ID'leri atla
                if !baseTerms.isAppleApp && helperBundleId.hasPrefix("com.apple.") { continue }

                let helperTerms = SearchTerms(bundleIds: [helperBundleId], nameTokenSets: [], isAppleApp: baseTerms.isAppleApp)
                results.append(contentsOf: searchLaunchItemsForHelper(searchTerms: helperTerms))
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
                if searchTerms.matchesBundleId(plistURL.lastPathComponent) {
                    results.append(Candidate(
                        url: plistURL,
                        kind: kind,
                        note: "Helper: \(dirURL.lastPathComponent)",
                        strength: .strong
                    ))
                }
            }
        }

        return results
    }

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
            guard searchTerms.match(receiptBase, isDirectory: false) == .strong else { continue }

            results.append(Candidate(
                url: url,
                kind: .other,
                note: "Installer Receipt",
                strength: .strong
            ))
        }

        return results
    }
}
