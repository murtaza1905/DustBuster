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

    public init(entries: [Entry], generated: String = "", source: String = "") {
        self.entries = entries
        self.generated = generated
        self.source = source

        var byApp: [String: [Int]] = [:]
        var byId: [String: [Int]] = [:]
        var byName: [String: [Int]] = [:]
        for (i, e) in entries.enumerated() {
            for app in e.apps { byApp[app.lowercased(), default: []].append(i) }
            for id in e.quitIds + e.pkgutil + e.launchctl { byId[id.lowercased(), default: []].append(i) }
            for n in e.names { byName[CaskDatabase.squash(n), default: []].append(i) }
        }
        self.byApp = byApp
        self.byIdentifier = byId
        self.byName = byName
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

    /// Uygulamayı cask'lere eşler. Öncelik: .app dosya adı → bundle ID (yalnızca tek cask
    /// talip ise) → görünen ad. Birden fazla cask aynı .app adını taşıyorsa (sürümler) birleşim alınır.
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
