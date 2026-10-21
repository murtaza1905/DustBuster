import Foundation

/// Tek bir kalıntı bulgusu.
public struct Finding: Codable, Equatable, Hashable {
    public enum Source: String, Codable {
        /// Bırakılan uygulama paketi
        case appBundle
        /// Bundle ID / tam adla birebir bilinen yol (hızlı tarama)
        case exactPath
        /// Dizin taramasında bundle ID eşleşmesi
        case bundleId
        /// Dizin taramasında ad eşleşmesi
        case name
        /// Homebrew Cask veritabanı
        case cask
        /// Paket içindeki yardımcı uygulamanın kendi konteyneri / launchd kaydı
        case helper
        /// Kurulum faturası (pkgutil): fatura dosyası veya paketin kurduğu dosya
        case receipt
        /// Uygulamanın entitlements beyanı (app group)
        case entitlement
        /// Konteyner metadata'sındaki sahip bundle ID'si
        case containerMetadata
        /// launchd plist'inin programı uygulama paketinin içinde
        case launchd
        /// Uygulama başına elle tanımlı kural (conditions.json)
        case condition
    }

    public let path: String
    public let kind: LeftoverKind
    public let source: Source
    public let strength: MatchStrength
    public let note: String

    public init(path: String, kind: LeftoverKind, source: Source, strength: MatchStrength, note: String) {
        self.path = path
        self.kind = kind
        self.source = source
        self.strength = strength
        self.note = note
    }

    public var isSelectedByDefault: Bool { strength == .strong }
}

public struct RejectedPath: Codable, Equatable {
    public let path: String
    public let reason: String
    public init(path: String, reason: String) { self.path = path; self.reason = reason }
}

public struct ScanResult: Equatable {
    public var findings: [Finding]
    /// Derin tarama güvenlik sınırını aştıysa atılan sonuç sayısı
    public var droppedDeepCount: Int
    /// Eşleşen Homebrew cask token'ları
    public var caskTokens: [String]
    /// Kabul edilmeyen yollar (rapor için)
    public var rejected: [RejectedPath]
    /// Uygulamaya ait bulunan kurulum paketi kimlikleri (pkgutil)
    public var receiptIds: [String]
    /// Uygulanan kural kimlikleri (conditions.json)
    public var conditionIds: [String]

    public init(findings: [Finding], droppedDeepCount: Int = 0, caskTokens: [String] = [], rejected: [RejectedPath] = [],
                receiptIds: [String] = [], conditionIds: [String] = []) {
        self.findings = findings
        self.droppedDeepCount = droppedDeepCount
        self.caskTokens = caskTokens
        self.rejected = rejected
        self.receiptIds = receiptIds
        self.conditionIds = conditionIds
    }

    public var strong: [Finding] { findings.filter { $0.strength == .strong } }
    public var weak: [Finding] { findings.filter { $0.strength == .weak } }
    public func contains(path: String) -> Bool { findings.contains { $0.path == path } }
}

/// Uygulama kalıntılarını bulan çekirdek. Dosya sistemine yalnızca `ScanFileSystem` üzerinden
/// dokunur; hiçbir şey silmez, boyut hesaplamaz.
public final class LeftoverScanner {
    public let home: String
    public let fs: ScanFileSystem
    public let caskDatabase: CaskDatabase?
    public let receipts: ReceiptProvider?
    public let conditions: AppConditions?
    public let options: ScanOptions

    private var homeLibrary: String { home + "/Library" }
    private let systemLibrary = "/Library"

    public init(home: String, fs: ScanFileSystem, caskDatabase: CaskDatabase?, receipts: ReceiptProvider? = nil,
                conditions: AppConditions? = nil, options: ScanOptions = ScanOptions()) {
        self.home = home
        self.fs = fs
        self.caskDatabase = caskDatabase
        self.receipts = receipts
        self.conditions = conditions
        self.options = options
    }

    // MARK: - Dış API

    /// Hızlı tarama: yalnızca birebir bilinen yollar + veritabanı. Anında sonuç verir.
    public func scanFast(identity: AppIdentity) -> ScanResult {
        let terms = SearchTerms(identity: identity)
        var collected = Collector(home: home, options: options)
        collected.add(appBundle(identity))
        for c in fastCandidates(identity: identity, terms: terms) { collected.add(c) }
        for c in entitlementCandidates(identity: identity) { collected.add(c) }
        for c in helperContainerCandidates(identity: identity) { collected.add(c) }
        let entries = addCaskHits(identity: identity, into: &collected)
        let tokens = entries.map { $0.token }
        let matched = addConditionHits(identity: identity, caskTokens: tokens, into: &collected)
        applyExclusions(conditions: matched, to: &collected)
        downgradeVendorFolders(identity: identity, in: &collected)
        collected.finalizeEmptyDirectories(isEmpty: isEmptyDirectory)
        return collected.result(droppedDeep: 0, caskTokens: tokens, conditionIds: matched.map { $0.id })
    }

    /// Tam tarama: kesin kaynaklar + veritabanı + dizin taraması (+ sistem konumları seçiliyse).
    public func scan(identity: AppIdentity) -> ScanResult {
        let terms = SearchTerms(identity: identity)
        var collected = Collector(home: home, options: options)
        collected.add(appBundle(identity))
        for c in fastCandidates(identity: identity, terms: terms) { collected.add(c) }
        for c in entitlementCandidates(identity: identity) { collected.add(c) }
        for c in helperContainerCandidates(identity: identity) { collected.add(c) }
        for c in containerMetadataCandidates(identity: identity) { collected.add(c) }
        for c in launchdCandidates(identity: identity) { collected.add(c) }
        let entries = addCaskHits(identity: identity, into: &collected)
        let tokens = entries.map { $0.token }
        let receiptIds = addReceiptHits(identity: identity, caskPkgIds: entries.flatMap { $0.pkgutil }, into: &collected)
        let matchedConditions = addConditionHits(identity: identity, caskTokens: tokens, into: &collected)

        var deep: [Finding] = []
        deep += searchUserLibrary(terms: terms)
        deep += searchByHost(terms: terms)
        deep += searchCrashReports(terms: terms)
        deep += searchHelperLaunchItems(identity: identity)
        if options.includeSystemLocations {
            deep += searchSystemLocations(terms: terms)
            deep += searchInstallerReceipts(terms: terms, receiptIds: receiptIds)
        }

        var dropped = 0
        if deep.count > options.maxReasonableResults {
            dropped = deep.count
        } else {
            let matched = Set(tokens)
            for f in deep {
                // Ad benzerliğiyle bulunan yol başka bir uygulamanın Homebrew kaydında geçiyorsa o uygulamaya aittir
                if f.strength == .weak, !collected.contains(f.path), options.useCaskDatabase, let db = caskDatabase {
                    let owners = db.otherOwners(ofPath: f.path, home: home, excluding: matched, identity: identity)
                    if !owners.isEmpty {
                        collected.reject(f.path, "başka uygulamaya ait (Homebrew: \(owners.joined(separator: ", ")))")
                        continue
                    }
                }
                collected.add(f)
            }
        }
        applyExclusions(conditions: matchedConditions, to: &collected)
        downgradeVendorFolders(identity: identity, in: &collected)
        collected.finalizeEmptyDirectories(isEmpty: isEmptyDirectory)
        return collected.result(droppedDeep: dropped, caskTokens: tokens, receiptIds: receiptIds,
                                conditionIds: matchedConditions.map { $0.id })
    }

    /// Filtresiz ham liste: standart konumlarda, ayraçlar atıldığında adında bundle ID'yi veya
    /// uygulama adını içeren TÜM yollar. Eşleştiricinin atladıklarını görmek için (rapor).
    public func rawMentions(identity: AppIdentity, limit: Int = 300) -> (needles: [String], paths: [String]) {
        let terms = SearchTerms(identity: identity)
        var needles: [String] = []
        for bid in terms.bundleIds {
            let squashed = SearchTerms.tokens(of: bid).joined()
            if squashed.count >= 4 && !needles.contains(squashed) { needles.append(squashed) }
        }
        for set in terms.nameTokenSets {
            let squashed = set.joined()
            if squashed.count >= 4 && !needles.contains(squashed) { needles.append(squashed) }
            for token in set where token.count >= 5 && !SearchTerms.genericNames.contains(token) && !needles.contains(token) {
                needles.append(token)
            }
        }
        guard !needles.isEmpty else { return (needles, []) }

        let locations: [(String, Int)] = [
            ("Application Support", 3), ("Caches", 2), ("Preferences", 1), ("Preferences/ByHost", 1),
            ("Logs", 2), ("Saved Application State", 1), ("Containers", 1), ("Group Containers", 1),
            ("LaunchAgents", 1), ("HTTPStorages", 1), ("WebKit", 1), ("Cookies", 1),
            ("Application Scripts", 1), ("Internet Plug-Ins", 1), ("PreferencePanes", 1),
            ("QuickLook", 1), ("Services", 1), ("Spotlight", 1), ("Frameworks", 1),
            ("Mail/Bundles", 1), ("Developer", 2)
        ]
        var found: [String] = []
        var seen: Set<String> = []
        for (sub, depth) in locations {
            let root = homeLibrary + "/" + sub
            collectMentions(root: root, dir: root, needles: needles, maxDepth: depth, depth: 0, into: &found, seen: &seen, limit: limit)
            if found.count >= limit { break }
        }
        return (needles, found)
    }

    // MARK: - Toplayıcı

    private struct Collector {
        let home: String
        let options: ScanOptions
        private var byPath: [String: Finding] = [:]
        private var order: [String] = []
        private(set) var rejected: [RejectedPath] = []

        init(home: String, options: ScanOptions) { self.home = home; self.options = options }

        mutating func add(_ finding: Finding) {
            if let existing = byPath[finding.path] {
                // Aynı yol iki kaynaktan geldiyse güçlü olanı ve birleşik notu sakla
                if finding.strength > existing.strength || (finding.source == .cask && existing.source != .cask) {
                    let note = existing.note == finding.note ? finding.note : "\(finding.note) + \(existing.note)"
                    byPath[finding.path] = Finding(path: finding.path, kind: existing.kind, source: finding.source,
                                                   strength: max(existing.strength, finding.strength), note: note)
                }
                return
            }
            byPath[finding.path] = finding
            order.append(finding.path)
        }

        mutating func reject(_ path: String, _ reason: String) {
            rejected.append(RejectedPath(path: path, reason: reason))
        }

        var paths: [String] { order }

        func contains(_ path: String) -> Bool { byPath[path] != nil }

        mutating func downgrade(_ path: String, note: String) {
            guard let f = byPath[path], f.strength == .strong else { return }
            byPath[path] = Finding(path: f.path, kind: f.kind, source: f.source, strength: .weak, note: "\(f.note) — \(note)")
        }

        mutating func remove(_ path: String, reason: String) {
            guard byPath.removeValue(forKey: path) != nil else { return }
            order.removeAll { $0 == path }
            rejected.append(RejectedPath(path: path, reason: reason))
        }

        /// Boş klasörler: uygulamanın kendi kabukları (güçlü) "boş klasör" etiketiyle listelenir; yalnızca zayıf
        /// kanıtla bulunan boş klasörler (paylaşılan grup, ad benzerliği) kazanç getirmediği için elenir.
        mutating func finalizeEmptyDirectories(isEmpty: (String) -> Bool) {
            for path in order {
                guard let f = byPath[path], isEmpty(path) else { continue }
                if f.strength == .weak {
                    remove(path, reason: "boş klasör, yalnızca zayıf eşleşme")
                } else {
                    byPath[path] = Finding(path: f.path, kind: f.kind, source: f.source, strength: f.strength, note: "\(f.note) — boş klasör")
                }
            }
        }

        func result(droppedDeep: Int, caskTokens: [String], receiptIds: [String] = [], conditionIds: [String] = []) -> ScanResult {
            let findings = order.compactMap { byPath[$0] }.sorted { a, b in
                if a.strength != b.strength { return a.strength > b.strength }
                let ra = LeftoverScanner.kindRank(a.kind), rb = LeftoverScanner.kindRank(b.kind)
                if ra != rb { return ra < rb }
                return a.path.localizedCaseInsensitiveCompare(b.path) == .orderedAscending
            }
            return ScanResult(findings: findings, droppedDeepCount: droppedDeep, caskTokens: caskTokens, rejected: rejected,
                              receiptIds: receiptIds, conditionIds: conditionIds)
        }
    }

    static func kindRank(_ kind: LeftoverKind) -> Int {
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

    // MARK: - Kaynaklar

    private func appBundle(_ identity: AppIdentity) -> Finding {
        Finding(path: identity.appPath, kind: .appBundle, source: .appBundle, strength: .strong, note: "Uygulama Paketi")
    }

    private func make(_ path: String, source: Finding.Source, strength: MatchStrength, note: String) -> Finding {
        Finding(path: path, kind: PathClassifier.kind(forPath: path, home: home), source: source, strength: strength, note: note)
    }

    /// Diskte var ve symlink değil.
    private func isUsable(_ path: String) -> Bool {
        fs.exists(path) && !fs.isSymlink(path)
    }

    private func isEmptyDirectory(_ path: String) -> Bool {
        fs.isDirectory(path) && fs.isEffectivelyEmptyDirectory(path)
    }

    private func fastCandidates(identity: AppIdentity, terms: SearchTerms) -> [Finding] {
        guard let bundleId = identity.bundleId, !bundleId.isEmpty else { return [] }
        let lib = homeLibrary
        var out: [Finding] = []
        let useAppName = !terms.nameTokenSets.isEmpty
        let appName = identity.name

        func addIfUsable(_ path: String, _ note: String) {
            if isUsable(path) { out.append(make(path, source: .exactPath, strength: .strong, note: note)) }
        }

        addIfUsable("\(lib)/Preferences/\(bundleId).plist", "Preferences")
        addIfUsable("\(lib)/Saved Application State/\(bundleId).savedState", "Saved State")
        addIfUsable("\(lib)/Containers/\(bundleId)", "Containers")
        addIfUsable("\(lib)/Application Support/\(bundleId)", "App Support (bundle ID)")
        addIfUsable("\(lib)/Caches/\(bundleId)", "Caches (bundle ID)")
        addIfUsable("\(lib)/Logs/\(bundleId)", "Logs (bundle ID)")
        addIfUsable("\(lib)/HTTPStorages/\(bundleId)", "HTTPStorages")
        addIfUsable("\(lib)/WebKit/\(bundleId)", "WebKit")
        if useAppName {
            addIfUsable("\(lib)/Application Support/\(appName)", "App Support (ad)")
            addIfUsable("\(lib)/Caches/\(appName)", "Caches (ad)")
            addIfUsable("\(lib)/Logs/\(appName)", "Logs (ad)")
        }

        for (sub, note) in [("Preferences/ByHost", "ByHost"), ("Group Containers", "Group Containers"), ("LaunchAgents", "LaunchAgents")] {
            let dir = "\(lib)/\(sub)"
            guard let names = fs.contents(ofDirectory: dir) else { continue }
            for name in names where terms.matchesBundleId(name) {
                let path = "\(dir)/\(name)"
                if isUsable(path) { out.append(make(path, source: .exactPath, strength: .strong, note: note)) }
            }
        }
        return out
    }

    private func addCaskHits(identity: AppIdentity, into collector: inout Collector) -> [CaskDatabase.Entry] {
        guard options.useCaskDatabase, let db = caskDatabase else { return [] }
        let entries = db.lookup(identity: identity)
        guard !entries.isEmpty else { return [] }
        let appPath = identity.appPath
        let matchedTokens = Set(entries.map { $0.token })
        for hit in db.expand(entries: entries, home: home, fs: fs) {
            // Uygulamanın kendisi ve içi ayrı ele alınır
            if hit.path == appPath || hit.path.hasPrefix(appPath + "/") { continue }
            switch PathClassifier.admit(path: hit.path, home: home, options: options) {
            case .accepted(let admitted, let note):
                guard isUsable(hit.path) else { collector.reject(hit.path, "symlink veya yok"); continue }
                var strength = admitted
                var label = "Homebrew: \(hit.token)" + (note.map { " — \($0)" } ?? "")
                // Aynı yolu başka cask'ler de sahipleniyorsa (ortak güncelleyici, satıcı kimlik grubu) paylaşılıyordur
                let others = db.otherOwners(ofPath: hit.path, home: home, excluding: matchedTokens, identity: identity)
                if !others.isEmpty {
                    strength = .weak
                    label += " — paylaşılan (\(others.prefix(3).joined(separator: ", "))), kontrol et"
                }
                collector.add(make(hit.path, source: .cask, strength: strength, note: label))
            case .rejected(let reason):
                collector.reject(hit.path, "Homebrew \(hit.token): \(reason)")
            }
        }
        return entries
    }

    // MARK: - Uygulama başına kurallar (Tur C)

    private func addConditionHits(identity: AppIdentity, caskTokens: [String], into collector: inout Collector) -> [AppCondition] {
        guard let conditions = conditions else { return [] }
        let matched = conditions.matching(identity: identity, caskTokens: caskTokens)
        guard !matched.isEmpty else { return [] }
        let appPath = identity.appPath
        for hit in conditions.expand(conditions: matched, home: home, fs: fs) {
            if hit.path == appPath || hit.path.hasPrefix(appPath + "/") { continue }
            switch PathClassifier.admit(path: hit.path, home: home, options: options) {
            case .accepted(let admitted, let note):
                guard isUsable(hit.path) else { collector.reject(hit.path, "symlink veya yok"); continue }
                var label = "Kural: \(hit.conditionId)"
                if let ruleNote = hit.note { label += " — \(ruleNote)" }
                if let note = note { label += " — \(note)" }
                collector.add(make(hit.path, source: .condition, strength: min(admitted, hit.strength), note: label))
            case .rejected(let reason):
                collector.reject(hit.path, "Kural \(hit.conditionId): \(reason)")
            }
        }
        return matched
    }

    /// Bundle ID'deki satıcı adı: "com.microsoft.word" → "microsoft", "notion.id" → "notion".
    static func vendorToken(identity: AppIdentity) -> String? {
        let parts = (identity.bundleId ?? "").lowercased().split(separator: ".").map(String.init)
        let vendor: String
        if parts.count >= 3 { vendor = parts[1] } else if parts.count == 2 { vendor = parts[0] } else { return nil }
        return SearchTerms.tokens(of: vendor).joined()
    }

    /// "~/Library/Application Support/Microsoft" gibi satıcı adını taşıyan klasörler aynı satıcının diğer
    /// ürünleriyle paylaşılır; uygulamanın adı satıcı adının kendisi değilse seçimsiz bırakılır.
    private func downgradeVendorFolders(identity: AppIdentity, in collector: inout Collector) {
        guard let vendor = LeftoverScanner.vendorToken(identity: identity), vendor.count >= 3 else { return }
        let nameSquashed = SearchTerms.tokens(of: identity.name).joined()
        guard nameSquashed != vendor else { return }
        let prefix = homeLibrary + "/"
        for path in collector.paths where path.hasPrefix(prefix) {
            let rel = path.dropFirst(prefix.count).split(separator: "/").map(String.init)
            guard rel.count == 1 || rel.count == 2, let last = rel.last else { continue }
            guard SearchTerms.tokens(of: last).joined() == vendor else { continue }
            collector.downgrade(path, note: "satıcı klasörü, aynı satıcının diğer ürünleri de kullanıyor olabilir — kontrol et")
        }
    }

    private func applyExclusions(conditions matched: [AppCondition], to collector: inout Collector) {
        guard let conditions = conditions, !matched.isEmpty else { return }
        for path in collector.paths {
            if let id = conditions.exclusion(forPath: path, home: home, conditions: matched) {
                collector.remove(path, reason: "Kural \(id) hariç tutuyor")
            }
        }
    }

    // MARK: - Kesin kaynaklar (Tur B)

    /// Uygulamayı (satıcıyı değil) tanımlayan token'lar: bundle ID'nin satıcıdan sonraki parçaları ve
    /// uygulama adı. Satıcı adı yalnızca uygulama adını içeriyorsa sayılır ("getupnote" ⊃ "upnote").
    static func appSpecificTokens(identity: AppIdentity) -> Set<String> {
        let ignored: Set<String> = ["desktop", "ios", "macos", "mobile", "shared", "private", "family", "group", "team"]
        var tokens: Set<String> = []
        let parts = (identity.bundleId ?? "").lowercased().split(separator: ".").map(String.init)
        let vendor = parts.count >= 2 ? parts[1] : ""
        for part in parts.dropFirst(2) { tokens.formUnion(SearchTerms.tokens(of: part)) }
        for set in SearchTerms(identity: identity).nameTokenSets {
            for t in set where t != vendor { tokens.insert(t) }
        }
        let nameSquashed = SearchTerms.tokens(of: identity.name).joined()
        if !vendor.isEmpty, nameSquashed.count >= SearchTerms.minNameLength, vendor.contains(nameSquashed) {
            tokens.insert(vendor)
        }
        return tokens.filter { $0.count >= 3 && !SearchTerms.genericNames.contains($0) && !ignored.contains($0) }
    }

    /// Entitlements'taki app group'lar: Group Containers ve Application Scripts altındaki tam yollar.
    /// Adı uygulamaya özgü olmayan gruplar (ör. satıcının ortak kimlik doğrulama grubu) başka
    /// uygulamalarla paylaşılıyor olabilir; seçimsiz listelenir.
    private func entitlementCandidates(identity: AppIdentity) -> [Finding] {
        let specific = LeftoverScanner.appSpecificTokens(identity: identity)
        var out: [Finding] = []
        for group in identity.appGroups where !group.isEmpty {
            let groupTokens = SearchTerms.tokens(of: group)
            // "OfficeExcelWidget" gibi birleşik grup adlarında uygulama adı alt dize olarak aranır (≥ 4 karakter);
            // grup adları uygulamanın kendi beyanı olduğu için alt dize burada güvenlidir
            let isSpecific = !Set(groupTokens).isDisjoint(with: specific)
                || groupTokens.contains { g in specific.contains { $0.count >= 4 && g.count > $0.count && g.contains($0) } }
            for (sub, note) in [("Group Containers", "Group Containers"), ("Application Scripts", "Application Scripts")] {
                let path = "\(homeLibrary)/\(sub)/\(group)"
                guard isUsable(path) else { continue }
                if isSpecific {
                    out.append(make(path, source: .entitlement, strength: .strong, note: "Entitlement app group: \(note)"))
                } else {
                    out.append(make(path, source: .entitlement, strength: .weak, note: "Entitlement app group: \(note) — satıcının ortak grubu olabilir, kontrol et"))
                }
            }
        }
        return out
    }

    /// Gömülü yardımcıların (uzantı, XPC, LoginItem) kendi konteyner ve script klasörleri.
    private func helperContainerCandidates(identity: AppIdentity) -> [Finding] {
        var out: [Finding] = []
        for id in identity.embeddedBundleIds where !id.isEmpty && !id.lowercased().hasPrefix("com.apple.") {
            for (sub, note) in [("Containers", "Containers"), ("Application Scripts", "Application Scripts"), ("Group Containers", "Group Containers")] {
                let path = "\(homeLibrary)/\(sub)/\(id)"
                if isUsable(path) {
                    out.append(make(path, source: .helper, strength: .strong, note: "Yardımcı \(id): \(note)"))
                }
            }
        }
        return out
    }

    /// ~/Library/Containers altındaki her klasörün metadata'sındaki sahip ID'si; klasör adı UUID olsa da eşleşir.
    private func containerMetadataCandidates(identity: AppIdentity) -> [Finding] {
        let dir = homeLibrary + "/Containers"
        guard let names = fs.contents(ofDirectory: dir) else { return [] }
        var owners: Set<String> = []
        if let bid = identity.bundleId?.lowercased(), !bid.isEmpty { owners.insert(bid) }
        for id in identity.embeddedBundleIds where !id.lowercased().hasPrefix("com.apple.") { owners.insert(id.lowercased()) }
        guard !owners.isEmpty else { return [] }

        var out: [Finding] = []
        for name in names {
            let path = dir + "/" + name
            guard fs.isDirectory(path), !fs.isSymlink(path) else { continue }
            guard let owner = fs.containerIdentifier(ofContainerAt: path)?.lowercased(), owners.contains(owner) else { continue }
            guard isUsable(path) else { continue }
            out.append(make(path, source: .containerMetadata, strength: .strong, note: "Konteyner metadata: \(owner)"))
        }
        return out
    }

    /// launchd plist'inin programı uygulama paketinin içindeyse kesin kalıntıdır (etiket ne olursa olsun).
    private func launchdCandidates(identity: AppIdentity) -> [Finding] {
        var dirs = [homeLibrary + "/LaunchAgents"]
        if options.includeSystemLocations { dirs += ["/Library/LaunchAgents", "/Library/LaunchDaemons"] }
        let appPrefix = identity.appPath + "/"
        var out: [Finding] = []
        for dir in dirs {
            guard let names = fs.contents(ofDirectory: dir) else { continue }
            for name in names where name.hasSuffix(".plist") {
                let path = dir + "/" + name
                guard !fs.isSymlink(path), let program = fs.launchdProgram(ofPlistAt: path) else { continue }
                guard program == identity.appPath || program.hasPrefix(appPrefix) else { continue }
                out.append(make(path, source: .launchd, strength: .strong, note: "launchd programı paket içinde: \((program as NSString).lastPathComponent)"))
            }
        }
        return out
    }

    /// Kurulum faturaları: uygulamaya ait paketlerin kurduğu dosyalar (yalnızca sistem taraması açıkken).
    private func addReceiptHits(identity: AppIdentity, caskPkgIds: [String], into collector: inout Collector) -> [String] {
        guard let provider = receipts else { return identity.receiptIds }
        let all = provider.installedPackageIds()
        var ids = ReceiptMatcher.matchingPackageIds(all: all, identity: identity, caskPkgIds: caskPkgIds)
        for id in identity.receiptIds where !ids.contains(id) { ids.append(id) }
        guard !ids.isEmpty, options.includeSystemLocations else { return ids }

        var files: [String] = []
        for id in ids { files += provider.files(forPackage: id) }
        for path in ReceiptMatcher.collapse(files: files, appPath: identity.appPath, home: home) {
            switch PathClassifier.admit(path: path, home: home, options: options) {
            case .accepted(let strength, let note):
                guard isUsable(path) else { continue }
                collector.add(make(path, source: .receipt, strength: strength, note: "Kurulum faturası" + (note.map { " — \($0)" } ?? "")))
            case .rejected(let reason):
                collector.reject(path, "Kurulum faturası: \(reason)")
            }
        }
        return ids
    }

    private struct Location {
        let subpath: String
        let recursive: Bool
    }

    private func searchUserLibrary(terms: SearchTerms) -> [Finding] {
        let base: [Location] = [
            Location(subpath: "Application Support", recursive: true),
            Location(subpath: "Caches", recursive: true),
            Location(subpath: "Preferences", recursive: false),
            Location(subpath: "Logs", recursive: true),
            Location(subpath: "Saved Application State", recursive: false),
            Location(subpath: "Containers", recursive: false),
            Location(subpath: "Group Containers", recursive: false),
            Location(subpath: "LaunchAgents", recursive: false),
            Location(subpath: "HTTPStorages", recursive: false),
            Location(subpath: "Cookies", recursive: false),
            Location(subpath: "Application Scripts", recursive: false),
            Location(subpath: "Caches/com.apple.nsurlsessiond/Downloads", recursive: false),
            Location(subpath: "Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments", recursive: false)
        ]
        let aggressive: [Location] = [
            Location(subpath: "WebKit", recursive: true),
            Location(subpath: "Internet Plug-Ins", recursive: false),
            Location(subpath: "PreferencePanes", recursive: false),
            Location(subpath: "QuickLook", recursive: false),
            Location(subpath: "Screen Savers", recursive: false),
            Location(subpath: "Services", recursive: false),
            Location(subpath: "Spotlight", recursive: false),
            Location(subpath: "Input Methods", recursive: false),
            Location(subpath: "Frameworks", recursive: true),
            Location(subpath: "ColorPickers", recursive: false),
            Location(subpath: "Address Book Plug-Ins", recursive: false),
            Location(subpath: "Mail/Bundles", recursive: false),
            Location(subpath: "Developer", recursive: true)
        ]
        let locations = base + (options.includeAggressiveLocations ? aggressive : [])
        var out: [Finding] = []
        for loc in locations {
            let root = homeLibrary + "/" + loc.subpath
            guard fs.isDirectory(root) else { continue }
            out += searchDirectory(root: root, dir: root, terms: terms, maxDepth: loc.recursive ? 3 : 1, depth: 0, system: false)
        }
        return out
    }

    private func searchDirectory(root: String, dir: String, terms: SearchTerms, maxDepth: Int, depth: Int, system: Bool) -> [Finding] {
        guard depth < maxDepth, let names = fs.contents(ofDirectory: dir) else { return [] }
        var out: [Finding] = []
        for name in names {
            let path = dir + "/" + name
            if fs.isSymlink(path) { continue }
            let isDir = fs.isDirectory(path)
            let relative = SearchTerms.relativePath(of: path, under: root)

            if let strength = terms.match(relative, isDirectory: isDir) {
                if system && strength != .strong { continue }
                guard isUsable(path) else { continue }
                // Yalnızca ad benzerliğiyle bulunan boş klasörler gürültüdür
                if strength == .weak && isEmptyDirectory(path) { continue }
                let source: Finding.Source = terms.matchesBundleId(name) ? .bundleId : .name
                out.append(make(path, source: source, strength: strength, note: (dir as NSString).lastPathComponent))
            } else if isDir {
                // Apple klasörlerinin içine inme (uygulama Apple'ın değilse)
                if !terms.isAppleApp && name.lowercased().hasPrefix("com.apple.") { continue }
                out += searchDirectory(root: root, dir: path, terms: terms, maxDepth: maxDepth, depth: depth + 1, system: system)
            }
        }
        return out
    }

    private func searchByHost(terms: SearchTerms) -> [Finding] {
        let dir = homeLibrary + "/Preferences/ByHost"
        guard let names = fs.contents(ofDirectory: dir) else { return [] }
        return names.compactMap { name in
            let path = dir + "/" + name
            guard !fs.isSymlink(path), let strength = terms.match(name, isDirectory: false), isUsable(path) else { return nil }
            if strength == .weak && isEmptyDirectory(path) { return nil }
            return make(path, source: terms.matchesBundleId(name) ? .bundleId : .name, strength: strength, note: "Preferences/ByHost")
        }
    }

    private func searchCrashReports(terms: SearchTerms) -> [Finding] {
        var out: [Finding] = []
        for sub in ["Logs/DiagnosticReports", "Logs/CrashReporter", "Application Support/CrashReporter"] {
            let dir = homeLibrary + "/" + sub
            guard let names = fs.contents(ofDirectory: dir) else { continue }
            for name in names {
                let path = dir + "/" + name
                guard let strength = terms.match(name, isDirectory: fs.isDirectory(path)), isUsable(path) else { continue }
                if strength == .weak && isEmptyDirectory(path) { continue }
                out.append(make(path, source: terms.matchesBundleId(name) ? .bundleId : .name, strength: strength, note: (sub as NSString).lastPathComponent))
            }
        }
        return out
    }

    /// Paket içindeki yardımcı uygulamaların bundle ID'leriyle yalnızca launchd konumları taranır.
    private func searchHelperLaunchItems(identity: AppIdentity) -> [Finding] {
        let helperIds = identity.embeddedBundleIds.map { $0.lowercased() }.filter { !$0.isEmpty && !$0.hasPrefix("com.apple.") }
        guard !helperIds.isEmpty else { return [] }
        let helperTerms = SearchTerms(bundleIds: helperIds, nameTokenSets: [], isAppleApp: identity.isAppleApp)
        var dirs = [homeLibrary + "/LaunchAgents"]
        if options.includeSystemLocations { dirs += ["/Library/LaunchAgents", "/Library/LaunchDaemons"] }
        var out: [Finding] = []
        for dir in dirs {
            guard let names = fs.contents(ofDirectory: dir) else { continue }
            for name in names where name.hasSuffix(".plist") && helperTerms.matchesBundleId(name) {
                let path = dir + "/" + name
                guard isUsable(path) else { continue }
                out.append(make(path, source: .helper, strength: .strong, note: "Yardımcı: \((dir as NSString).lastPathComponent)"))
            }
        }
        return out
    }

    private func searchSystemLocations(terms: SearchTerms) -> [Finding] {
        let locations: [Location] = [
            Location(subpath: "Application Support", recursive: true),
            Location(subpath: "LaunchAgents", recursive: false),
            Location(subpath: "LaunchDaemons", recursive: false),
            Location(subpath: "PrivilegedHelperTools", recursive: false),
            Location(subpath: "Preferences", recursive: false),
            Location(subpath: "Frameworks", recursive: true),
            Location(subpath: "Logs/DiagnosticReports", recursive: false)
        ]
        var out: [Finding] = []
        for loc in locations {
            let root = systemLibrary + "/" + loc.subpath
            guard fs.isDirectory(root) else { continue }
            out += searchDirectory(root: root, dir: root, terms: terms, maxDepth: loc.recursive ? 2 : 1, depth: 0, system: true)
        }
        return out
    }

    private func searchInstallerReceipts(terms: SearchTerms, receiptIds: [String]) -> [Finding] {
        let dir = "/private/var/db/receipts"
        guard let names = fs.contents(ofDirectory: dir) else { return [] }
        let known = Set(receiptIds.map { $0.lowercased() })
        var out: [Finding] = []
        for name in names where name.hasSuffix(".bom") || name.hasSuffix(".plist") {
            let base = (name as NSString).deletingPathExtension
            guard known.contains(base.lowercased()) || terms.match(base, isDirectory: false) == .strong else { continue }
            out.append(Finding(path: dir + "/" + name, kind: .other, source: .receipt, strength: .strong, note: "Kurulum faturası dosyası"))
        }
        return out
    }

    private func collectMentions(root: String, dir: String, needles: [String], maxDepth: Int, depth: Int,
                                 into found: inout [String], seen: inout Set<String>, limit: Int) {
        guard depth < maxDepth, found.count < limit, let names = fs.contents(ofDirectory: dir) else { return }
        for name in names {
            if found.count >= limit { return }
            let path = dir + "/" + name
            if fs.isSymlink(path) { continue }
            let squashed = SearchTerms.tokens(of: SearchTerms.relativePath(of: path, under: root)).joined()
            if needles.contains(where: { squashed.contains($0) }) {
                if seen.insert(path).inserted { found.append(path) }
                continue
            }
            if fs.isDirectory(path) {
                collectMentions(root: root, dir: path, needles: needles, maxDepth: maxDepth, depth: depth + 1, into: &found, seen: &seen, limit: limit)
            }
        }
    }
}
