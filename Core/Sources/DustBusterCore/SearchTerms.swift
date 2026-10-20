import Foundation

/// Bir kalıntının uygulamaya ne kadar güvenle bağlandığı.
public enum MatchStrength: String, Codable, Comparable {
    /// Bundle ID / Homebrew veritabanı / birebir ad → varsayılan seçili
    case strong
    /// Uygulama adı, daha uzun bir adın parçası olarak geçiyor → seçimsiz, kullanıcı kontrol eder
    case weak

    public static func < (lhs: MatchStrength, rhs: MatchStrength) -> Bool {
        lhs == .weak && rhs == .strong
    }
}

/// Arama kriterleri. Yalnızca iki şey eşleşir:
///  1) Bundle ID (tam, alt paket, grup veya takım-ID önekli biçimleri)
///  2) Uygulama adı — kelime sınırıyla (alt dize araması yapılmaz)
/// Geliştirici öneki, bundle ID'nin son parçası veya telif hakkındaki şirket adı gibi aynı
/// geliştiricinin BAŞKA uygulamalarını da yakalayan terimler bilinçli olarak kullanılmaz.
public struct SearchTerms: Equatable {
    /// Küçük harfli bundle ID'ler (ana uygulama)
    public let bundleIds: [String]
    /// Uygulama adı varyantları, küçük harfli ve token'lara ayrılmış
    public let nameTokenSets: [[String]]
    public let isAppleApp: Bool

    public static let minNameLength = 4

    /// Tek başına bir uygulamayı tanımlamayan, çok sayıda yanlış eşleşme üreten adlar.
    public static let genericNames: Set<String> = [
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

    /// Aynı uygulamanın ayrı dağıtım kanalları (Chrome Canary, X Beta…) ayrı uygulama sayılır.
    public static let channelWords: Set<String> = [
        "canary", "beta", "dev", "nightly", "alpha", "insiders", "insider", "preview", "rc"
    ]

    public init(bundleIds: [String], nameTokenSets: [[String]], isAppleApp: Bool) {
        self.bundleIds = bundleIds
        self.nameTokenSets = nameTokenSets
        self.isAppleApp = isAppleApp
    }

    public init(identity: AppIdentity) {
        var ids: [String] = []
        if let bid = identity.bundleId?.lowercased(), !bid.isEmpty { ids.append(bid) }

        var extraNames: [String] = []
        if let exe = identity.executableName, exe != identity.name { extraNames.append(exe) }
        let stem = identity.appFileStem
        if stem != identity.name { extraNames.append(stem) }

        self.init(
            bundleIds: ids,
            nameTokenSets: SearchTerms.makeNameTokenSets(appName: identity.name, extraNames: extraNames),
            isAppleApp: identity.isAppleApp
        )
    }

    // MARK: - Yardımcılar

    public static func tokens(of text: String) -> [String] {
        text.lowercased()
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .map(String.init)
    }

    /// Uygulama adı ve varyantlarından token kümeleri üretir; genel/kısa adları eler.
    public static func makeNameTokenSets(appName: String, extraNames: [String]) -> [[String]] {
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

    public static func containsContiguous(_ needle: [String], in haystack: [String]) -> Bool {
        guard !needle.isEmpty, needle.count <= haystack.count else { return false }
        let last = haystack.count - needle.count
        for start in 0...last where Array(haystack[start..<(start + needle.count)]) == needle {
            return true
        }
        return false
    }

    /// `name` içinde `bid.` ifadesinden hemen sonra gelen bileşen; yoksa "".
    public static func component(after bid: String, in name: String) -> String {
        guard let range = name.range(of: bid + ".") else { return "" }
        let rest = name[range.upperBound...]
        return rest.split(separator: ".").first.map(String.init) ?? ""
    }

    /// Arama kökünden itibaren göreli yol ("Google/Chrome"); kök dışındaysa yalnızca son bileşen.
    public static func relativePath(of path: String, under root: String) -> String {
        if path.hasPrefix(root + "/") {
            return String(path.dropFirst(root.count + 1))
        }
        return (path as NSString).lastPathComponent
    }

    // MARK: - Eşleştirme

    public func matchesBundleId(_ name: String) -> Bool {
        let n = name.lowercased()
        for bid in bundleIds {
            let isMatch = n == bid
                || n.hasPrefix(bid + ".")
                || n.hasSuffix("." + bid)
                || n.contains("." + bid + ".")
            guard isMatch else { continue }
            // com.google.chrome.canary → Chrome'un değil, Canary'nin dosyası
            let next = SearchTerms.component(after: bid, in: n)
            if SearchTerms.channelWords.contains(next) { continue }
            return true
        }
        return false
    }

    /// Verilen yolun (arama köküne göre göreli, ör. "Google/Chrome") uygulamaya ait olup
    /// olmadığını ve eşleşme gücünü döner. Tek bileşenli adlar da aynı yoldan geçer.
    public func match(_ relativePath: String, isDirectory: Bool = false) -> MatchStrength? {
        let lower = relativePath.lowercased()
        let lastComponent = lower.split(separator: "/").last.map(String.init) ?? lower

        // Apple'a ait adlar: kaldırılan uygulama Apple'ın değilse asla eşleşmez
        if !isAppleApp && (lastComponent == "com.apple" || lastComponent.hasPrefix("com.apple.")) {
            return nil
        }

        if matchesBundleId(lastComponent) {
            return .strong
        }

        guard !nameTokenSets.isEmpty else { return nil }

        let pathTokens = SearchTerms.tokens(of: lower)
        guard !pathTokens.isEmpty else { return nil }

        var lastTokens = SearchTerms.tokens(of: lastComponent)
        if !isDirectory, let dot = lastComponent.lastIndex(of: "."), dot != lastComponent.startIndex {
            lastTokens = SearchTerms.tokens(of: String(lastComponent[..<dot]))
        }

        // "Chrome Canary", "X Beta" gibi kanal türevleri ayrı uygulamadır (yolun herhangi bir yerinde)
        for token in pathTokens where SearchTerms.channelWords.contains(token) {
            let termHasIt = nameTokenSets.contains { $0.contains(token) }
            if !termHasIt { return nil }
        }

        for termTokens in nameTokenSets where lastTokens == termTokens || pathTokens == termTokens {
            return .strong
        }

        // Zayıf eşleşme yalnızca girdinin KENDİ adında aranır; üst klasör adları kredilendirilmez
        // ("Google/Chrome Remote Desktop/Default" Chrome'a ait değildir)
        for termTokens in nameTokenSets where SearchTerms.containsContiguous(termTokens, in: lastTokens) {
            return .weak
        }
        return nil
    }

    /// Rapor için okunabilir açıklama.
    public func describe() -> [String] {
        var lines: [String] = []
        lines.append("Bundle ID: " + (bundleIds.isEmpty ? "-" : bundleIds.joined(separator: ", ")))
        if nameTokenSets.isEmpty {
            lines.append("Ad eşleşmesi: kullanılmadı (ad genel veya 4 karakterden kısa)")
        } else {
            let sets = nameTokenSets.map { "[" + $0.joined(separator: " ") + "]" }
            lines.append("Ad token'ları: " + sets.joined(separator: ", "))
        }
        lines.append("Apple uygulaması: " + (isAppleApp ? "evet" : "hayır"))
        return lines
    }
}
