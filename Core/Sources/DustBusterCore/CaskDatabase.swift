import Foundation

/// Homebrew Cask tanımlarından derlenen, uygulamaya gömülü kalıntı veritabanı.
/// Kaynak: Homebrew/homebrew-cask (BSD-2-Clause). Ağ erişimi yoktur; `tools/build-cask-db.py`
/// ile üretilen `cask-zap.json` paket kaynağı olarak gömülüdür.
public final class CaskDatabase {
    public struct Entry: Codable, Equatable {
        public let token: String
        public let names: [String]
        public let apps: [String]
        public let quitIds: [String]
        public let launchctl: [String]
        public let pkgutil: [String]
        public let trash: [String]
        public let delete: [String]
        public let rmdir: [String]

        enum CodingKeys: String, CodingKey {
            case token = "t", names = "n", apps = "a", quitIds = "q", launchctl = "l", pkgutil = "p", zap = "z"
        }

        enum ZapKeys: String, CodingKey { case trash, delete, rmdir }

        public init(token: String, names: [String], apps: [String], quitIds: [String], launchctl: [String],
                    pkgutil: [String], trash: [String], delete: [String], rmdir: [String]) {
            self.token = token; self.names = names; self.apps = apps; self.quitIds = quitIds
            self.launchctl = launchctl; self.pkgutil = pkgutil; self.trash = trash; self.delete = delete; self.rmdir = rmdir
        }

        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            token = try c.decode(String.self, forKey: .token)
            names = try c.decodeIfPresent([String].self, forKey: .names) ?? []
            apps = try c.decodeIfPresent([String].self, forKey: .apps) ?? []
            quitIds = try c.decodeIfPresent([String].self, forKey: .quitIds) ?? []
            launchctl = try c.decodeIfPresent([String].self, forKey: .launchctl) ?? []
            pkgutil = try c.decodeIfPresent([String].self, forKey: .pkgutil) ?? []
            let z = try c.nestedContainer(keyedBy: ZapKeys.self, forKey: .zap)
            trash = try z.decodeIfPresent([String].self, forKey: .trash) ?? []
            delete = try z.decodeIfPresent([String].self, forKey: .delete) ?? []
            rmdir = try z.decodeIfPresent([String].self, forKey: .rmdir) ?? []
        }

        public func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(token, forKey: .token)
            try c.encode(names, forKey: .names)
            try c.encode(apps, forKey: .apps)
            try c.encode(quitIds, forKey: .quitIds)
            try c.encode(launchctl, forKey: .launchctl)
            try c.encode(pkgutil, forKey: .pkgutil)
            var z = c.nestedContainer(keyedBy: ZapKeys.self, forKey: .zap)
            try z.encode(trash, forKey: .trash)
            try z.encode(delete, forKey: .delete)
            try z.encode(rmdir, forKey: .rmdir)
        }

        /// Kaldırma adayı olarak kullanılacak kalıplar (trash + delete).
        public var leftoverPatterns: [String] { trash + delete }
    }

    struct File: Codable {
        let schema: Int
        let generated: String
        let source: String
        let count: Int
        let casks: [Entry]
    }

    public let generated: String
    public let source: String
    public let entries: [Entry]

    private let byApp: [String: [Int]]
    private let byIdentifier: [String: [Int]]
    private let byName: [String: [Int]]
    /// Joker içermeyen "~/…" kalıpları → sahibi cask'ler (başka uygulamaya ait dosyaları tanımak için)
    private let ownersByExactPath: [String: [Int]]
    /// Jokerli "~/…" kalıpları, jokerden önceki üst dizine göre gruplanmış
    private let globOwnersByParent: [String: [(pattern: String, index: Int)]]
    /// Her cask'in zap yollarında geçen (Apple dışı) bundle ID benzeri bileşenler
    private let zapBundleIds: [Set<String>]
    /// Bundle ID → onu zap yollarında anan cask'ler
    private let byZapBundleId: [String: [Int]]

    public init(entries: [Entry], generated: String = "", source: String = "") {
        self.entries = entries
        self.generated = generated
        self.source = source

        var byApp: [String: [Int]] = [:]
        var byId: [String: [Int]] = [:]
        var byName: [String: [Int]] = [:]
        var owners: [String: [Int]] = [:]
        var globOwners: [String: [(pattern: String, index: Int)]] = [:]
        var zapIds: [Set<String>] = []
        var byZap: [String: [Int]] = [:]
        for (i, e) in entries.enumerated() {
            var ids: Set<String> = []
            for p in e.leftoverPatterns where p.hasPrefix("~/") {
                for component in CaskDatabase.bundleLikeComponents(ofPattern: p) { ids.insert(component) }
            }
            zapIds.append(ids)
            for id in ids { byZap[id, default: []].append(i) }
            for app in e.apps { byApp[app.lowercased(), default: []].append(i) }
            // `quit:` kimlikleri kullanılmaz: başka uygulamaları da (ör. bir eklenti kurucusunun kapattığı
            // Chrome'u) kapsar; yalnızca paket kimlikleri ve launchd etiketleri uygulamayı tanımlar
            for id in e.pkgutil + e.launchctl { byId[id.lowercased(), default: []].append(i) }
            for n in e.names { byName[CaskDatabase.squash(n), default: []].append(i) }
            for p in e.leftoverPatterns where p.hasPrefix("~/") {
                let lower = p.lowercased()
                if Glob.hasWildcard(lower) {
                    // Jokerden önceki sabit üst dizin: "~/library/preferences/notion.mail.id.*" → "~/library/preferences"
                    let components = lower.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
                    guard let firstWild = components.firstIndex(where: Glob.hasWildcard), firstWild > 0 else { continue }
                    let parent = components[0..<firstWild].joined(separator: "/")
                    globOwners[parent, default: []].append((pattern: lower, index: i))
                } else {
                    owners[lower, default: []].append(i)
                }
            }
        }
        self.byApp = byApp
        self.byIdentifier = byId
        self.byName = byName
        self.ownersByExactPath = owners
        self.globOwnersByParent = globOwners
        self.zapBundleIds = zapIds
        self.byZapBundleId = byZap
    }

    /// "~/Library/Containers/com.microsoft.Excel*" → ["com.microsoft.excel"]. Uzantılar ve jokerler atılır,
    /// en az iki nokta içeren, boşluksuz, Apple dışı bileşenler alınır.
    static func bundleLikeComponents(ofPattern pattern: String) -> [String] {
        var out: [String] = []
        for raw in pattern.lowercased().split(separator: "/").dropFirst(2) {
            var c = String(raw)
            if let star = c.firstIndex(where: { $0 == "*" || $0 == "?" }) { c = String(c[..<star]) }
            for suffix in [".plist", ".savedstate", ".sfl4", ".sfl3", ".sfl2", ".sfl", ".binarycookies"] where c.hasSuffix(suffix) {
                c = String(c.dropLast(suffix.count))
            }
            while c.hasSuffix(".") { c.removeLast() }
            guard c.filter({ $0 == "." }).count >= 2, !c.contains(" "), !c.hasPrefix("com.apple.") else { continue }
            out.append(c)
        }
        return out
    }

    /// Cask'in zap listesi bu bundle ID'yi anıyorsa o cask aynı uygulamanın (sürüm/paket) kaydıdır.
    public func caskMentions(token: String, bundleId: String) -> Bool {
        guard let index = entries.firstIndex(where: { $0.token == token }) else { return false }
        return zapBundleIds[index].contains(bundleId.lowercased())
    }

    /// Yol, `excluding` dışındaki bir cask'in zap listesinde birebir geçiyorsa o cask'lerin token'larını döner.
    /// "Notion Calendar" klasörünün Notion'a değil notion-calendar'a ait olduğunu böyle anlarız.
    public func otherOwners(ofPath path: String, home: String, excluding tokens: Set<String>, identity: AppIdentity? = nil) -> [String] {
        guard path.hasPrefix(home + "/") else { return [] }
        let key = ("~" + String(path.dropFirst(home.count))).lowercased()
        var indices: [Int] = ownersByExactPath[key] ?? []

        // Jokerli kalıplar: yolun üst dizinlerinden birine kayıtlı kalıplar denenir
        var parent = key
        while let slash = parent.lastIndex(of: "/") {
            parent = String(parent[..<slash])
            if let candidates = globOwnersByParent[parent] {
                for candidate in candidates where Glob.matches(candidate.pattern, key) {
                    indices.append(candidate.index)
                }
            }
            if parent == "~" { break }
        }

        var seen: Set<Int> = []
        return indices.filter { seen.insert($0).inserted }
            .filter { !isSameApp(index: $0, as: identity) }
            .map { entries[$0].token }.filter { !tokens.contains($0) }
    }

    /// Cask, bu uygulamanın başka bir kaydı mı? Uygulama listesi bizim .app'imizi içeriyorsa (Office paketi
    /// Excel'i taşır) ya da uygulama listesi boşken zap yolları bizim bundle ID'mizi anıyorsa (pkg tabanlı
    /// microsoft-excel) aynı uygulamadır; "Google Chrome Beta.app" taşıyan cask ise başka uygulamadır.
    private func isSameApp(index: Int, as identity: AppIdentity?) -> Bool {
        guard let identity = identity else { return false }
        let e = entries[index]
        let appKey = identity.appFileName.lowercased()
        if e.apps.contains(where: { $0.lowercased() == appKey }) { return true }
        if e.apps.isEmpty, let bid = identity.bundleId?.lowercased(), zapBundleIds[index].contains(bid) { return true }
        return false
    }

    public convenience init(jsonData: Data) throws {
        let file = try JSONDecoder().decode(File.self, from: jsonData)
        self.init(entries: file.casks, generated: file.generated, source: file.source)
    }

    /// Pakete gömülü anlık görüntü.
    public static func bundled() -> CaskDatabase? {
        guard let url = Bundle.module.url(forResource: "cask-zap", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? CaskDatabase(jsonData: data)
    }

    public var count: Int { entries.count }

    static func squash(_ s: String) -> String {
        SearchTerms.tokens(of: s).joined()
    }

    /// Uygulamayı cask'lere eşler. Öncelik: .app dosya adı → bundle ID (pkgutil/launchctl kaydı,
    /// yalnızca tek cask talip ise) → görünen ad. Birden fazla cask aynı .app adını taşıyorsa
    /// (sürümler) en özgül olanlar alınır.
    public func lookup(identity: AppIdentity) -> [Entry] {
        var indices: [Int] = []

        let appKey = identity.appFileName.lowercased()
        if let found = byApp[appKey] { indices = found }

        if indices.isEmpty, let bid = identity.bundleId?.lowercased(),
           let found = byIdentifier[bid], found.count == 1 {
            indices = found
        }

        if indices.isEmpty {
            let nameKey = CaskDatabase.squash(identity.name)
            if nameKey.count >= SearchTerms.minNameLength, let found = byName[nameKey], found.count == 1 {
                indices = found
            }
        }

        // .app adı yalnızca paket cask'lerinde (Office) geçiyorsa, zap listesi doğrudan bu bundle ID'yi
        // anan ve başka uygulamaya değinmeyen tekil cask (microsoft-excel) tercih edilir
        if let bid = identity.bundleId?.lowercased(), !bid.isEmpty,
           indices.allSatisfy({ entries[$0].apps.count > 1 }) {
            let specific = (byZapBundleId[bid] ?? []).filter { i in
                let e = entries[i]
                let otherApps = e.apps.filter { $0.lowercased() != appKey }
                return otherApps.isEmpty && zapBundleIds[i].count <= 2
            }
            if !specific.isEmpty {
                let minCount = specific.map { zapBundleIds[$0].count }.min() ?? 0
                indices = specific.filter { zapBundleIds[$0].count == minCount }
            }
        }

        var seen: Set<Int> = []
        let unique = indices.filter { seen.insert($0).inserted }.map { entries[$0] }

        // Aynı .app adını birden fazla cask taşıyorsa (ör. uygulama + içinde bulunduğu paket),
        // yalnızca en az uygulama içeren (en özgül) cask'ler kalır. Office paketi Teams'i,
        // Teams cask'i ise sadece Teams'i taşır → Teams cask'i seçilir.
        guard let minApps = unique.map({ max($0.apps.count, 1) }).min() else { return unique }
        return unique.filter { max($0.apps.count, 1) == minApps }
    }

    /// Bulunan cask'lerin kalıplarını diskte var olan yollara açar.
    public struct Hit: Equatable {
        public let path: String
        public let pattern: String
        public let token: String
    }

    public func expand(entries: [Entry], home: String, fs: ScanFileSystem) -> [Hit] {
        var hits: [Hit] = []
        var seen: Set<String> = []
        for entry in entries {
            for pattern in entry.leftoverPatterns {
                for path in Glob.expand(pattern: pattern, home: home, fs: fs) where seen.insert(path).inserted {
                    hits.append(Hit(path: path, pattern: pattern, token: entry.token))
                }
            }
        }
        return hits
    }
}
