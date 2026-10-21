import Foundation

/// Test vakası: bir uygulama kimliği, sanal bir ~/Library ağacı ve beklenen sonuç.
/// Uygulamadaki "Test vakası dışa aktar" düğmesi bu biçimde JSON üretir; testler aynı biçimi okur.
public struct Fixture: Codable, Equatable {
    public struct Expectation: Codable, Equatable {
        /// Güçlü (seçili) bulunması gereken yollar
        public var strong: [String]
        /// Zayıf (seçimsiz) bulunması gereken yollar
        public var weak: [String]
        /// Hiç listelenmemesi gereken yollar (negatif kontroller)
        public var absent: [String]
        /// Eşleşmesi beklenen Homebrew cask token'ları (boşsa kontrol edilmez)
        public var caskTokens: [String]

        public init(strong: [String] = [], weak: [String] = [], absent: [String] = [], caskTokens: [String] = []) {
            self.strong = strong; self.weak = weak; self.absent = absent; self.caskTokens = caskTokens
        }
    }

    public struct Options: Codable, Equatable {
        public var includeSystemLocations: Bool
        public var includeAggressiveLocations: Bool
        public var useCaskDatabase: Bool

        public init(includeSystemLocations: Bool = false, includeAggressiveLocations: Bool = false, useCaskDatabase: Bool = true) {
            self.includeSystemLocations = includeSystemLocations
            self.includeAggressiveLocations = includeAggressiveLocations
            self.useCaskDatabase = useCaskDatabase
        }

        public var scanOptions: ScanOptions {
            ScanOptions(includeSystemLocations: includeSystemLocations,
                        includeAggressiveLocations: includeAggressiveLocations,
                        useCaskDatabase: useCaskDatabase)
        }
    }

    public var schema: Int
    public var name: String
    /// "observed" (uygulamadan dışa aktarıldı, henüz doğrulanmadı) veya "curated" (beklenti elle onaylandı)
    public var status: String
    public var notes: String
    public var home: String
    public var identity: AppIdentity
    public var options: Options
    /// Sanal diskteki yollar. "~" ev dizinine açılır; "/" ile bitenler dizindir ve dolu kabul edilir.
    public var tree: [String]
    /// Boş olması gereken dizinler (tarayıcı bunları listelememeli)
    public var emptyDirs: [String]
    /// ~/Library/Containers/<klasör> → metadata'daki sahip bundle ID'si (Tur B)
    public var containerIdentifiers: [String: String]?
    /// launchd plist yolu → çalıştırdığı program yolu (Tur B)
    public var launchdPrograms: [String: String]?
    /// Kurulum faturaları: paket kimliği → kurduğu dosyalar (Tur B)
    public var receipts: [String: [String]]?
    public var expect: Expectation

    public init(name: String, status: String = "curated", notes: String = "", home: String = "/Users/test",
                identity: AppIdentity, options: Options = Options(), tree: [String], emptyDirs: [String] = [],
                containerIdentifiers: [String: String]? = nil, launchdPrograms: [String: String]? = nil,
                receipts: [String: [String]]? = nil, expect: Expectation) {
        self.schema = 1
        self.name = name
        self.status = status
        self.notes = notes
        self.home = home
        self.identity = identity
        self.options = options
        self.tree = tree
        self.emptyDirs = emptyDirs
        self.containerIdentifiers = containerIdentifiers
        self.launchdPrograms = launchdPrograms
        self.receipts = receipts
        self.expect = expect
    }

    // MARK: - Yol yardımcıları

    public func expand(_ path: String) -> String {
        if path == "~" { return home }
        if path.hasPrefix("~/") { return home + String(path.dropFirst(1)) }
        return path
    }

    public func contract(_ path: String) -> String {
        if path == home { return "~" }
        if path.hasPrefix(home + "/") { return "~" + String(path.dropFirst(home.count)) }
        return path
    }

    /// Ağaçtan sanal disk kurar. Dolu dizinlere görünmez bir çocuk eklenir ki "boş klasör" sayılmasınlar.
    public func makeFileSystem() -> VirtualFileSystem {
        var paths: [String] = []
        for raw in tree {
            let p = expand(raw)
            if p.hasSuffix("/") {
                paths.append(p)
                paths.append(p + "_")
            } else {
                paths.append(p)
            }
        }
        for raw in emptyDirs {
            let p = expand(raw)
            paths.append(p.hasSuffix("/") ? p : p + "/")
        }
        // Uygulama paketinin kendisi de diskte olsun
        let appPath = expand(identity.appPath)
        paths.append(appPath + "/")
        paths.append(appPath + "/Contents/Info.plist")

        var containers: [String: String] = [:]
        for (path, id) in containerIdentifiers ?? [:] { containers[expand(path)] = id }
        var programs: [String: String] = [:]
        for (path, program) in launchdPrograms ?? [:] {
            programs[expand(path)] = expand(program)
            if !paths.contains(expand(path)) { paths.append(expand(path)) }
        }
        return VirtualFileSystem(paths: paths, containerIdentifiers: containers, launchdPrograms: programs)
    }

    public func makeReceiptProvider() -> StaticReceiptProvider {
        var packages: [String: [String]] = [:]
        for (id, files) in receipts ?? [:] { packages[id] = files.map(expand) }
        return StaticReceiptProvider(packages: packages)
    }

    public func makeIdentity() -> AppIdentity {
        var id = identity
        id.appPath = expand(identity.appPath)
        return id
    }

    // MARK: - Çalıştırma ve karşılaştırma

    public struct Verdict: Equatable {
        public var missingStrong: [String] = []
        public var missingWeak: [String] = []
        public var wrongStrength: [String] = []
        public var unexpectedPresent: [String] = []
        public var missingCaskTokens: [String] = []
        public var unexpectedExtras: [String] = []

        public var passed: Bool {
            missingStrong.isEmpty && missingWeak.isEmpty && wrongStrength.isEmpty && unexpectedPresent.isEmpty && missingCaskTokens.isEmpty
        }

        public var summary: String {
            var lines: [String] = []
            if !missingStrong.isEmpty { lines.append("GÜÇLÜ beklenen ama bulunmayan: " + missingStrong.joined(separator: ", ")) }
            if !missingWeak.isEmpty { lines.append("ZAYIF beklenen ama bulunmayan: " + missingWeak.joined(separator: ", ")) }
            if !wrongStrength.isEmpty { lines.append("Yanlış güç: " + wrongStrength.joined(separator: ", ")) }
            if !unexpectedPresent.isEmpty { lines.append("Listelenmemesi gerekirken listelenen: " + unexpectedPresent.joined(separator: ", ")) }
            if !missingCaskTokens.isEmpty { lines.append("Eşleşmeyen cask: " + missingCaskTokens.joined(separator: ", ")) }
            if !unexpectedExtras.isEmpty { lines.append("Beklentide olmayan ek bulgular (bilgi): " + unexpectedExtras.joined(separator: ", ")) }
            return lines.joined(separator: "\n")
        }
    }

    public func run(caskDatabase: CaskDatabase?) -> (ScanResult, Verdict) {
        let fs = makeFileSystem()
        let scanner = LeftoverScanner(home: home, fs: fs, caskDatabase: caskDatabase,
                                      receipts: makeReceiptProvider(), options: options.scanOptions)
        let result = scanner.scan(identity: makeIdentity())
        return (result, verdict(for: result))
    }

    public func verdict(for result: ScanResult) -> Verdict {
        var v = Verdict()
        var strengthByPath: [String: MatchStrength] = [:]
        for f in result.findings { strengthByPath[f.path] = f.strength }

        for raw in expect.strong {
            let p = expand(raw)
            switch strengthByPath[p] {
            case .none: v.missingStrong.append(raw)
            case .some(.weak): v.wrongStrength.append("\(raw) (zayıf, güçlü bekleniyordu)")
            case .some(.strong): break
            }
        }
        for raw in expect.weak {
            let p = expand(raw)
            switch strengthByPath[p] {
            case .none: v.missingWeak.append(raw)
            case .some(.strong): v.wrongStrength.append("\(raw) (güçlü, zayıf bekleniyordu)")
            case .some(.weak): break
            }
        }
        for raw in expect.absent where strengthByPath[expand(raw)] != nil {
            v.unexpectedPresent.append(raw)
        }
        for token in expect.caskTokens where !result.caskTokens.contains(token) {
            v.missingCaskTokens.append(token)
        }
        let expectedPaths = Set((expect.strong + expect.weak).map(expand))
        let appPath = expand(identity.appPath)
        for f in result.findings where !expectedPaths.contains(f.path) && f.path != appPath {
            v.unexpectedExtras.append(contract(f.path) + " [\(f.strength.rawValue), \(f.source.rawValue)]")
        }
        return v
    }

    // MARK: - Uygulamadan dışa aktarma

    /// Gerçek bir taramanın sonucundan "observed" durumunda bir vaka üretir.
    public static func capture(name: String, home: String, identity: AppIdentity, options: ScanOptions,
                               result: ScanResult, rawMentions: [String], isDirectory: (String) -> Bool,
                               isEmptyDirectory: (String) -> Bool = { _ in false },
                               containerIdentifier: (String) -> String? = { _ in nil },
                               launchdProgram: (String) -> String? = { _ in nil }) -> Fixture {
        var fixture = Fixture(
            name: name,
            status: "observed",
            notes: "Uygulamadan dışa aktarıldı; beklenti gözlemle aynı, elle doğrulanmalı.",
            home: "/Users/test",
            identity: identity,
            options: Options(includeSystemLocations: options.includeSystemLocations,
                             includeAggressiveLocations: options.includeAggressiveLocations,
                             useCaskDatabase: options.useCaskDatabase),
            tree: [],
            expect: Expectation()
        )
        func anonymize(_ path: String) -> String {
            if path == home { return "~" }
            if path.hasPrefix(home + "/") { return "~" + String(path.dropFirst(home.count)) }
            return path
        }
        fixture.identity.appPath = anonymize(identity.appPath)

        var tree: Set<String> = []
        var empty: Set<String> = []
        func place(_ path: String) {
            if isDirectory(path) {
                if isEmptyDirectory(path) { empty.insert(anonymize(path) + "/") } else { tree.insert(anonymize(path) + "/") }
            } else {
                tree.insert(anonymize(path))
            }
        }
        for f in result.findings where f.source != .appBundle { place(f.path) }
        for p in rawMentions { place(p) }
        for r in result.rejected { place(r.path) }
        fixture.tree = tree.sorted()
        fixture.emptyDirs = empty.sorted()

        // Kesin kaynakların yeniden oynatılabilmesi için metadata ve launchd programları da kaydedilir
        var containers: [String: String] = [:]
        var programs: [String: String] = [:]
        for f in result.findings {
            switch f.source {
            case .containerMetadata:
                if let owner = containerIdentifier(f.path) { containers[anonymize(f.path)] = owner }
            case .launchd:
                if let program = launchdProgram(f.path) { programs[anonymize(f.path)] = anonymize(program) }
            default:
                break
            }
        }
        fixture.containerIdentifiers = containers.isEmpty ? nil : containers
        fixture.launchdPrograms = programs.isEmpty ? nil : programs
        fixture.expect = Expectation(
            strong: result.findings.filter { $0.strength == .strong && $0.source != .appBundle }.map { anonymize($0.path) },
            weak: result.findings.filter { $0.strength == .weak }.map { anonymize($0.path) },
            absent: [],
            caskTokens: result.caskTokens
        )
        return fixture
    }

    public func jsonData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func load(from data: Data) throws -> Fixture {
        try JSONDecoder().decode(Fixture.self, from: data)
    }
}
