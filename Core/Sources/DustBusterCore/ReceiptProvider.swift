import Foundation

/// Kurulum faturası (pkgutil) kaynağı. Uygulama katmanı `/usr/sbin/pkgutil` ile doldurur,
/// testler sabit bir sözlükle.
public protocol ReceiptProvider {
    /// Sistemdeki tüm paket kimlikleri (`pkgutil --pkgs`)
    func installedPackageIds() -> [String]
    /// Paketin kurduğu dosyaların mutlak yolları (`pkgutil --files` + kurulum konumu)
    func files(forPackage id: String) -> [String]
}

/// Testler için sabit fatura kaynağı.
public struct StaticReceiptProvider: ReceiptProvider {
    public let packages: [String: [String]]

    public init(packages: [String: [String]]) {
        self.packages = packages
    }

    public func installedPackageIds() -> [String] { Array(packages.keys).sorted() }
    public func files(forPackage id: String) -> [String] { packages[id] ?? [] }
}

public enum ReceiptMatcher {
    /// Hangi paket kimlikleri bu uygulamaya ait? Bundle ID biçimleri, gömülü yardımcı ID'leri
    /// ve Homebrew'un cask için bildirdiği pkgutil kimlikleri (joker destekli).
    public static func matchingPackageIds(all: [String], identity: AppIdentity, caskPkgIds: [String]) -> [String] {
        let terms = SearchTerms(identity: identity)
        let helperIds = Set(identity.embeddedBundleIds.map { $0.lowercased() })
        let caskPatterns = caskPkgIds.map { $0.lowercased() }
        var out: [String] = []
        for id in all {
            let lower = id.lowercased()
            let byBundle = terms.matchesBundleId(lower)
            let byHelper = helperIds.contains(lower) || helperIds.contains { lower.hasPrefix($0 + ".") }
            let byCask = caskPatterns.contains { Glob.hasWildcard($0) ? Glob.matches($0, lower) : $0 == lower }
            if byBundle || byHelper || byCask { out.append(id) }
        }
        return out
    }

    /// Standart kökler: bunların doğrudan altındaki ilk bileşen kalıntı olarak listelenir
    /// ("/Library/Application Support/Logi/x/y" → "/Library/Application Support/Logi").
    static let standardRoots: [String] = [
        "/Library/Application Support", "/Library/LaunchAgents", "/Library/LaunchDaemons",
        "/Library/PrivilegedHelperTools", "/Library/Preferences", "/Library/Frameworks",
        "/Library/Extensions", "/Library/Internet Plug-Ins", "/Library/PreferencePanes",
        "/Library/Audio/Plug-Ins/Components", "/Library/Audio/Plug-Ins/VST", "/Library/Audio/Plug-Ins/VST3",
        "/Library/Input Methods", "/Library/QuickLook", "/Library/Services", "/Library/Logs",
        "/Library/Caches", "/Library/Fonts", "/Library/Scripts", "/Library/Printers",
        "/Applications/Utilities", "/Applications", "/Users/Shared",
        "/usr/local/bin", "/usr/local/lib", "/usr/local/share", "/usr/local/etc", "/usr/local/opt"
    ]

    /// Dosya listesini en sığ anlamlı atalarına indirger; uygulama paketinin içi atılır.
    public static func collapse(files: [String], appPath: String, home: String) -> [String] {
        var out: [String] = []
        var seen: Set<String> = []
        let userRoots = ["Application Support", "LaunchAgents", "Preferences", "Caches", "Logs", "Frameworks",
                         "Internet Plug-Ins", "PreferencePanes", "Services", "QuickLook", "Containers", "Group Containers"]
            .map { home + "/Library/" + $0 }
        let roots = standardRoots + userRoots

        for raw in files {
            let path = raw.hasSuffix("/") && raw.count > 1 ? String(raw.dropLast()) : raw
            guard path.hasPrefix("/") else { continue }
            if path == appPath || path.hasPrefix(appPath + "/") { continue }

            var collapsed: String?
            for root in roots where path.hasPrefix(root + "/") {
                let rest = path.dropFirst(root.count + 1)
                if let first = rest.split(separator: "/").first {
                    collapsed = root + "/" + String(first)
                    break
                }
            }
            guard let result = collapsed else { continue }
            if seen.insert(result).inserted { out.append(result) }
        }
        return out
    }
}
