import Foundation

/// Uygulama başına elle tanımlanmış kurallar: sezgisel taramanın bulamadığı kesin konumlar
/// (`include`) ve hiçbir kaynaktan listeye girmemesi gereken yollar (`exclude`).
/// Kaynak: paket içindeki `conditions.json`. Bir uygulamaya kural eklemek için dosyaya
/// kayıt eklemek yeterlidir; kod değişmez.
public struct AppCondition: Codable, Equatable {
    public struct Include: Codable, Equatable {
        public let path: String
        public let strength: MatchStrength
        public let note: String?

        public init(path: String, strength: MatchStrength = .strong, note: String? = nil) {
            self.path = path; self.strength = strength; self.note = note
        }

        enum CodingKeys: String, CodingKey { case path, strength, note }

        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            path = try c.decode(String.self, forKey: .path)
            strength = try c.decodeIfPresent(MatchStrength.self, forKey: .strength) ?? .strong
            note = try c.decodeIfPresent(String.self, forKey: .note)
        }
    }

    public let id: String
    /// Bundle ID birebir eşleşirse (büyük/küçük harf duyarsız) kural uygulanır
    public let bundleIds: [String]
    /// Taramada bu Homebrew cask token'larından biri eşleşirse kural uygulanır
    public let caskTokens: [String]
    public let include: [Include]
    /// Joker destekli "~/…" veya "/…" kalıpları; eşleşen bulgular kaynağı ne olursa olsun elenir
    public let exclude: [String]

    public init(id: String, bundleIds: [String] = [], caskTokens: [String] = [], include: [Include] = [], exclude: [String] = []) {
        self.id = id; self.bundleIds = bundleIds; self.caskTokens = caskTokens; self.include = include; self.exclude = exclude
    }

    enum CodingKeys: String, CodingKey { case id, bundleIds, caskTokens, include, exclude }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        bundleIds = try c.decodeIfPresent([String].self, forKey: .bundleIds) ?? []
        caskTokens = try c.decodeIfPresent([String].self, forKey: .caskTokens) ?? []
        include = try c.decodeIfPresent([Include].self, forKey: .include) ?? []
        exclude = try c.decodeIfPresent([String].self, forKey: .exclude) ?? []
    }

    public func matches(identity: AppIdentity, caskTokens matched: [String]) -> Bool {
        if let bid = identity.bundleId?.lowercased(), bundleIds.contains(where: { $0.lowercased() == bid }) { return true }
        return caskTokens.contains { token in matched.contains(token) }
    }
}

public final class AppConditions {
    struct File: Codable {
        let schema: Int
        let conditions: [AppCondition]
    }

    public let conditions: [AppCondition]

    public init(conditions: [AppCondition]) {
        self.conditions = conditions
    }

    public convenience init(jsonData: Data) throws {
        let file = try JSONDecoder().decode(File.self, from: jsonData)
        self.init(conditions: file.conditions)
    }

    public static func bundled() -> AppConditions? {
        guard let url = Bundle.module.url(forResource: "conditions", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? AppConditions(jsonData: data)
    }

    public var count: Int { conditions.count }

    public func matching(identity: AppIdentity, caskTokens: [String]) -> [AppCondition] {
        conditions.filter { $0.matches(identity: identity, caskTokens: caskTokens) }
    }

    public struct Hit: Equatable {
        public let path: String
        public let conditionId: String
        public let strength: MatchStrength
        public let note: String?
    }

    /// Eşleşen kuralların `include` kalıplarını diskte var olan yollara açar.
    public func expand(conditions matched: [AppCondition], home: String, fs: ScanFileSystem) -> [Hit] {
        var hits: [Hit] = []
        var seen: Set<String> = []
        for condition in matched {
            for rule in condition.include {
                for path in Glob.expand(pattern: rule.path, home: home, fs: fs) where seen.insert(path).inserted {
                    hits.append(Hit(path: path, conditionId: condition.id, strength: rule.strength, note: rule.note))
                }
            }
        }
        return hits
    }

    /// Yol, eşleşen kurallardan birinin `exclude` kalıbına uyuyorsa o kuralın kimliğini döner.
    public func exclusion(forPath path: String, home: String, conditions matched: [AppCondition]) -> String? {
        let contracted = path.hasPrefix(home + "/") ? "~" + String(path.dropFirst(home.count)) : path
        for condition in matched {
            for pattern in condition.exclude {
                if Glob.matches(pattern, contracted) || Glob.matches(pattern, path) { return condition.id }
            }
        }
        return nil
    }
}
