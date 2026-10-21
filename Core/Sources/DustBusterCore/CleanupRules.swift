import Foundation

/// Sistem Temizliği kuralları: taranan kökler, yasaklı kökler, hassas kelimeler, Apple servis
/// listesi, bölünecek satıcı klasörleri ve tarayıcı tanımları. Kaynak: paket içindeki `rules.json`.
public struct CleanupRules: Codable, Equatable {
    public struct Root: Codable, Equatable {
        public let path: String
        public let label: String
        public init(path: String, label: String) { self.path = path; self.label = label }
    }

    public struct Browsers: Codable, Equatable {
        public let chromiumProfileCacheFolders: [String]
        public let chromiumRootCacheFolders: [String]
        public let chromiumProfileNames: [String]
        public let chromiumProfilePrefixes: [String]
        public let chromiumSingleProfileRoots: [String]
        public let chromiumNames: [String: String]
        public let geckoProfileRoots: [String]
        public let geckoCacheFolder: String
        public let geckoNames: [String: String]
        public let safariCachePaths: [String]

        public init(chromiumProfileCacheFolders: [String], chromiumRootCacheFolders: [String], chromiumProfileNames: [String],
                    chromiumProfilePrefixes: [String], chromiumSingleProfileRoots: [String], chromiumNames: [String: String],
                    geckoProfileRoots: [String], geckoCacheFolder: String, geckoNames: [String: String], safariCachePaths: [String]) {
            self.chromiumProfileCacheFolders = chromiumProfileCacheFolders
            self.chromiumRootCacheFolders = chromiumRootCacheFolders
            self.chromiumProfileNames = chromiumProfileNames
            self.chromiumProfilePrefixes = chromiumProfilePrefixes
            self.chromiumSingleProfileRoots = chromiumSingleProfileRoots
            self.chromiumNames = chromiumNames
            self.geckoProfileRoots = geckoProfileRoots
            self.geckoCacheFolder = geckoCacheFolder
            self.geckoNames = geckoNames
            self.safariCachePaths = safariCachePaths
        }
    }

    public let schema: Int
    public let roots: [Root]
    public let forbiddenRoots: [String]
    public let sensitiveKeywords: [String]
    public let appleServicePrefixes: [String]
    public let appleServiceExceptions: [String]
    public let appleServiceNames: [String]
    public let vendorFolders: [String]
    public let browsers: Browsers

    public init(schema: Int = 1, roots: [Root], forbiddenRoots: [String], sensitiveKeywords: [String], appleServicePrefixes: [String],
                appleServiceExceptions: [String], appleServiceNames: [String], vendorFolders: [String], browsers: Browsers) {
        self.schema = schema
        self.roots = roots
        self.forbiddenRoots = forbiddenRoots
        self.sensitiveKeywords = sensitiveKeywords
        self.appleServicePrefixes = appleServicePrefixes
        self.appleServiceExceptions = appleServiceExceptions
        self.appleServiceNames = appleServiceNames
        self.vendorFolders = vendorFolders
        self.browsers = browsers
    }

    public static func load(from data: Data) throws -> CleanupRules {
        try JSONDecoder().decode(CleanupRules.self, from: data)
    }

    public static func bundled() -> CleanupRules? {
        guard let url = Bundle.module.url(forResource: "rules", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? load(from: data)
    }
}

/// Temizlik adayı: yol, arayüz etiketi ve türü. Boyut ve silinebilirlik uygulama katmanında ölçülür.
public struct CleanupCandidate: Equatable {
    public enum Category: String, Codable {
        case cache, log, browserCache, appleService
    }

    public let path: String
    public let label: String?
    public let category: Category

    public init(path: String, label: String?, category: Category) {
        self.path = path; self.label = label; self.category = category
    }

    public var isAppleService: Bool { category == .appleService }
}

/// Kuralları dosya sistemine uygular: tarayıcı önbelleklerini tespit eder, kök klasörlerin üst düzey
/// girdilerini (satıcı klasörlerini bölerek) listeler ve bir yolun silinip silinemeyeceğine karar verir.
public final class CleanupPolicy {
    public let rules: CleanupRules
    public let home: String
    public let fs: ScanFileSystem

    public struct ChromiumRoot: Equatable {
        /// "Google/Chrome" gibi, Application Support'a göre bağıl yol
        public let relative: String
        public let profiles: [String]
    }

    public private(set) var chromiumRoots: [ChromiumRoot] = []
    public private(set) var chromiumCachePaths: [String] = []

    public init(rules: CleanupRules, home: String, fs: ScanFileSystem) {
        self.rules = rules
        self.home = home
        self.fs = fs
    }

    // MARK: - Yol yardımcıları

    public func expand(_ path: String) -> String {
        if path == "~" { return home }
        if path.hasPrefix("~/") { return home + String(path.dropFirst(1)) }
        return path
    }

    public static func isPath(_ path: String, under root: String) -> Bool {
        path == root || path.hasPrefix(root + "/")
    }

    public var rootPaths: [String] { rules.roots.map { expand($0.path) } }
    public var geckoRoots: [String] { rules.browsers.geckoProfileRoots.map(expand) }
    public var safariPaths: [String] { rules.browsers.safariCachePaths.map(expand) }
    public var forbiddenRoots: [String] { rules.forbiddenRoots }
    public var sensitiveKeywords: [String] { rules.sensitiveKeywords }
    public var cachesRoot: String { expand("~/Library/Caches") }
    public var appSupportRoot: String { expand("~/Library/Application Support") }

    private func visibleChildren(of dir: String) -> [String] {
        (fs.contents(ofDirectory: dir) ?? []).filter { !$0.hasPrefix(".") }
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private func isVendorFolder(name: String) -> Bool {
        rules.vendorFolders.contains { $0.caseInsensitiveCompare(name) == .orderedSame }
    }

    // MARK: - Tarayıcılar

    /// Application Support altında (iki seviye) Chromium tabanlı tarayıcıları bulur; her tarayıcının
    /// hem Application Support hem de ~/Library/Caches altındaki (aynı bağıl yol) önbellek klasörlerini toplar.
    @discardableResult
    public func detectChromiumCaches() -> [String] {
        chromiumRoots = []
        chromiumCachePaths = []
        var relatives: [String] = []
        for name in visibleChildren(of: appSupportRoot) where !name.lowercased().hasPrefix("com.apple.") {
            let path = appSupportRoot + "/" + name
            guard fs.isDirectory(path), !fs.isSymlink(path) else { continue }
            relatives.append(name)
            for sub in visibleChildren(of: path) where !sub.lowercased().hasPrefix("com.apple.") {
                let subPath = path + "/" + sub
                if fs.isDirectory(subPath), !fs.isSymlink(subPath) { relatives.append(name + "/" + sub) }
            }
        }
        for relative in relatives { collectChromium(relative: relative) }
        return chromiumCachePaths
    }

    private func isProfileName(_ name: String) -> Bool {
        rules.browsers.chromiumProfileNames.contains(name) || rules.browsers.chromiumProfilePrefixes.contains { name.hasPrefix($0) }
    }

    private func collectChromium(relative: String) {
        let supportRoot = appSupportRoot + "/" + relative
        let mirrorRoot = cachesRoot + "/" + relative
        let children = visibleChildren(of: supportRoot)
        let hasLocalState = fs.exists(supportRoot + "/Local State")
        let profiles = children.filter(isProfileName)
        let b = rules.browsers

        func addIfDirectory(_ path: String) {
            guard fs.isDirectory(path), !fs.isSymlink(path), !chromiumCachePaths.contains(path) else { return }
            chromiumCachePaths.append(path)
        }

        if hasLocalState && !profiles.isEmpty {
            chromiumRoots.append(ChromiumRoot(relative: relative, profiles: profiles))
            for root in [supportRoot, mirrorRoot] {
                for profile in profiles {
                    for folder in b.chromiumProfileCacheFolders { addIfDirectory(root + "/" + profile + "/" + folder) }
                }
                for folder in b.chromiumRootCacheFolders { addIfDirectory(root + "/" + folder) }
            }
            return
        }

        let last = (relative as NSString).lastPathComponent
        if b.chromiumSingleProfileRoots.contains(where: { $0.caseInsensitiveCompare(last) == .orderedSame }) {
            chromiumRoots.append(ChromiumRoot(relative: relative, profiles: []))
            for root in [supportRoot, mirrorRoot] {
                for folder in b.chromiumProfileCacheFolders + b.chromiumRootCacheFolders { addIfDirectory(root + "/" + folder) }
            }
        }
    }

    /// ~/Library/Caches altındaki bir yol, tespit edilen bir Chromium tarayıcısının aynadaki kökü mü?
    public func isChromiumMirrorRoot(_ path: String) -> Bool {
        chromiumRoots.contains { cachesRoot + "/" + $0.relative == path }
    }

    public func chromiumBrowserName(relative: String) -> String {
        if let known = rules.browsers.chromiumNames[relative] { return known }
        let parts = relative.split(separator: "/").map(String.init)
        if let first = parts.first, let known = rules.browsers.chromiumNames[first] { return known }
        return parts.last ?? relative
    }

    private func chromiumLabel(path: String) -> String? {
        for root in chromiumRoots {
            for base in [appSupportRoot + "/" + root.relative, cachesRoot + "/" + root.relative] where path.hasPrefix(base + "/") {
                let rest = String(path.dropFirst(base.count + 1)).split(separator: "/").map(String.init)
                let folder = rest.last ?? ""
                let profile = rest.count > 1 ? rest[0] : ""
                let profileSuffix = rules.browsers.chromiumProfilePrefixes.contains(where: { profile.hasPrefix($0) }) ? " (\(profile))" : ""
                let type: String
                switch folder {
                case "GPUCache": type = "GPU Cache"
                case "ShaderCache", "GrShaderCache": type = "Shader Cache"
                case "GraphiteDawnCache", "DawnWebGPUCache", "DawnGraphiteCache": type = "GPU Shader Cache"
                default: type = folder
                }
                return "\(chromiumBrowserName(relative: root.relative))\(profileSuffix) \(type)"
            }
        }
        return nil
    }

    /// Tespit edilen Chromium önbellekleri + Gecko profil önbellekleri + Safari önbelleği.
    public func browserCandidates() -> [CleanupCandidate] {
        var out: [CleanupCandidate] = []
        for path in chromiumCachePaths {
            out.append(CleanupCandidate(path: path, label: chromiumLabel(path: path), category: .browserCache))
        }
        for root in geckoRoots where fs.isDirectory(root) {
            let family = (root as NSString).deletingLastPathComponent
            let familyName = (family as NSString).lastPathComponent
            let label = rules.browsers.geckoNames[familyName] ?? familyName
            for profile in visibleChildren(of: root) {
                let cache = root + "/" + profile + "/" + rules.browsers.geckoCacheFolder
                guard fs.isDirectory(cache), !fs.isSymlink(cache) else { continue }
                out.append(CleanupCandidate(path: cache, label: "\(label) Cache", category: .browserCache))
            }
        }
        for path in safariPaths where fs.exists(path) && !fs.isSymlink(path) {
            out.append(CleanupCandidate(path: path, label: "Safari Cache", category: .browserCache))
        }
        return out
    }

    /// Bir kök girdisi tarayıcı bölümünde ele alınıyorsa (Firefox/Safari kökü veya Chromium aynası) true.
    public func isBrowserOwned(_ path: String) -> Bool {
        if isChromiumMirrorRoot(path) { return true }
        if geckoRoots.contains(where: { CleanupPolicy.isPath(path, under: $0) || CleanupPolicy.isPath($0, under: path) }) { return true }
        if safariPaths.contains(where: { CleanupPolicy.isPath(path, under: $0) || CleanupPolicy.isPath($0, under: path) }) { return true }
        return false
    }

    // MARK: - Kök girdileri

    public enum RootDecision: Equatable {
        case listed(CleanupCandidate)
        case browser
        case split([CleanupCandidate])
    }

    /// Kökün üst düzey girdileri için karar: listele, tarayıcı bölümüne bırak, ya da satıcı klasörünü böl.
    public func decide(rootEntry path: String, rootLabel: String) -> RootDecision {
        if isBrowserOwned(path) { return .browser }
        let name = (path as NSString).lastPathComponent
        if isVendorFolder(name: name), fs.isDirectory(path), !fs.isSymlink(path) {
            var children: [CleanupCandidate] = []
            for child in visibleChildren(of: path) {
                let childPath = path + "/" + child
                if isBrowserOwned(childPath) { continue }
                let suffix = rootLabel == "Caches" ? " Cache" : (rootLabel == "Logs" ? " Logs" : "")
                children.append(CleanupCandidate(path: childPath, label: "\(name) › \(child)\(suffix)", category: category(for: childPath, rootLabel: rootLabel)))
            }
            return .split(children)
        }
        return .listed(CleanupCandidate(path: path, label: nil, category: category(for: path, rootLabel: rootLabel)))
    }

    public func rootCandidates() -> [CleanupCandidate] {
        var out: [CleanupCandidate] = []
        for root in rules.roots {
            let rootPath = expand(root.path)
            guard fs.isDirectory(rootPath) else { continue }
            for name in visibleChildren(of: rootPath) {
                switch decide(rootEntry: rootPath + "/" + name, rootLabel: root.label) {
                case .listed(let c): out.append(c)
                case .split(let cs): out += cs
                case .browser: break
                }
            }
        }
        return out
    }

    private func category(for path: String, rootLabel: String) -> CleanupCandidate.Category {
        if isAppleService(path: path) { return .appleService }
        return rootLabel == "Logs" ? .log : .cache
    }

    /// ~/Library/Caches altındaki Apple sistem servisi önbelleği mi? (Xcode gibi kullanıcı kurulumu Apple araçları hariç)
    public func isAppleService(path: String) -> Bool {
        guard CleanupPolicy.isPath(path, under: cachesRoot) else { return false }
        let name = (path as NSString).lastPathComponent
        let lower = name.lowercased()
        if rules.appleServiceExceptions.contains(where: { lower.hasPrefix($0.lowercased()) }) { return false }
        if rules.appleServicePrefixes.contains(where: { lower.hasPrefix($0.lowercased()) }) { return true }
        return rules.appleServiceNames.contains { $0.caseInsensitiveCompare(name) == .orderedSame }
    }

    // MARK: - Güvenlik kararı

    /// nil ise kurallara göre silinebilir; değilse neden silinemeyeceği. (macOS'un silinebilirlik
    /// işareti uygulama katmanında ayrıca kontrol edilir.)
    public func verdict(path: String) -> String? {
        let underRoot = rootPaths.contains { CleanupPolicy.isPath(path, under: $0) }
        let underChromium = chromiumCachePaths.contains { CleanupPolicy.isPath(path, under: $0) }
        let underGecko = geckoRoots.contains { CleanupPolicy.isPath(path, under: $0) }
        let underSafari = safariPaths.contains { CleanupPolicy.isPath(path, under: $0) }
        guard underRoot || underChromium || underGecko || underSafari else { return "izin verilen kökler dışında" }

        if !underSafari, let forbidden = rules.forbiddenRoots.first(where: { CleanupPolicy.isPath(path, under: $0) }) {
            return "yasaklı kök: \(forbidden)"
        }
        if path == home || path == "/" { return "home veya kök dizin" }

        if CleanupPolicy.isPath(path, under: appSupportRoot) && !underChromium {
            return "Application Support içinde, tespit edilen tarayıcı cache kökü değil"
        }

        if CleanupPolicy.isPath(path, under: cachesRoot) {
            let lower = path.lowercased()
            if let keyword = rules.sensitiveKeywords.first(where: { lower.contains($0.lowercased()) }) {
                return "hassas kelime: \(keyword)"
            }
        }
        return nil
    }

    // MARK: - Rapor

    public func scopeLines() -> [String] {
        var lines: [String] = []
        for root in rules.roots {
            let path = expand(root.path)
            lines.append("- \(path)" + (fs.isDirectory(path) ? "" : " (yok)"))
        }
        lines.append("- Chromium tarayıcıları (Application Support + Caches aynası), tespit edilen (\(chromiumRoots.count)):")
        for root in chromiumRoots {
            lines.append("    \(root.relative) — profiller: \(root.profiles.isEmpty ? "tek profil" : root.profiles.joined(separator: ", "))")
        }
        lines.append("- Chromium cache klasörleri (\(chromiumCachePaths.count)):")
        for path in chromiumCachePaths { lines.append("    \(path)") }
        let gecko = geckoRoots.filter { fs.isDirectory($0) }
        lines.append("- Gecko profil kökleri, mevcut (\(gecko.count)):")
        for path in gecko { lines.append("    \(path)") }
        let safari = safariPaths.filter { fs.exists($0) }
        lines.append("- Safari cache yolları, mevcut (\(safari.count)):")
        for path in safari { lines.append("    \(path)") }
        lines.append("- Bölünen satıcı klasörleri: " + rules.vendorFolders.joined(separator: ", "))
        let prefixes = rules.appleServicePrefixes.joined(separator: ", ")
        let exceptions = rules.appleServiceExceptions.joined(separator: ", ")
        let names = rules.appleServiceNames.joined(separator: ", ")
        lines.append("- Apple sistem servisi (listelenir, seçimsiz): önek \(prefixes) (hariç: \(exceptions)), ad: \(names)")
        lines.append("- Hassas anahtar kelimeler (~/Library/Caches altında engeller): " + rules.sensitiveKeywords.joined(separator: ", "))
        lines.append("- Yasaklı kökler: " + rules.forbiddenRoots.joined(separator: ", "))
        return lines
    }
}
