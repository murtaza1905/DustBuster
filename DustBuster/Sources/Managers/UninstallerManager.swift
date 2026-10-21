// Sources/Managers/UninstallerManager.swift

import Foundation
import Security
import DustBusterCore

/// Arayüzde kullanılan konum türü: çekirdekteki LeftoverKind'ın kendisi.
typealias UninstallItemKind = LeftoverKind

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
    /// Bulgunun kaynağı (Homebrew, bundle ID, ad…)
    let source: Finding.Source

    var isFromDatabase: Bool { source == .cask }

    /// Kesin kaynaklar için kısa rozet metni; sezgisel kaynaklarda nil
    var sourceBadge: String? {
        switch source {
        case .cask: return "Homebrew"
        case .entitlement: return "Entitlement"
        case .containerMetadata: return "Metadata"
        case .launchd: return "launchd"
        case .receipt: return "pkgutil"
        case .helper: return "Yardımcı"
        case .appBundle, .exactPath, .bundleId, .name: return nil
        }
    }
}

/// Uygulama katmanı: Info.plist ve gömülü paketlerden kimliği çıkarır, çekirdek tarayıcıyı
/// gerçek diskte çalıştırır, sonuçları arayüz öğelerine çevirir ve boyut hesaplar.
/// Eşleştirme mantığının tamamı DustBusterCore içindedir ve testlerle korunur.
final class UninstallerManager {
    static let maxReasonableResults = ScanOptions().maxReasonableResults

    private let fileManager = FileManager.default
    private let home: String
    private let fs = RealFileSystem()
    private let caskDatabase: CaskDatabase?
    private let receipts = PkgutilReceiptProvider()

    /// Sistem seviyesi konumları da taramak için true yap (/Library/)
    var includeSystemLocations: Bool = false
    /// WebKit / Developer / Frameworks vb. geniş tarama konumlarını dahil etmek için
    var includeAggressiveLocations: Bool = false
    /// Homebrew Cask veritabanını kullan
    var useCaskDatabase: Bool = true

    /// Son taramanın çekirdek sonucu (rapor ve test vakası dışa aktarımı için)
    private(set) var lastScanResult: ScanResult?
    private(set) var lastIdentity: AppIdentity?

    init() {
        home = fileManager.homeDirectoryForCurrentUser.path
        caskDatabase = CaskDatabase.bundled()
    }

    var options: ScanOptions {
        ScanOptions(includeSystemLocations: includeSystemLocations,
                    includeAggressiveLocations: includeAggressiveLocations,
                    useCaskDatabase: useCaskDatabase)
    }

    var databaseDescription: String {
        guard let db = caskDatabase else { return "Homebrew veritabanı: yüklenemedi" }
        return "Homebrew veritabanı: \(db.count) cask, \(db.generated), \(db.source)"
    }

    private func makeScanner() -> LeftoverScanner {
        LeftoverScanner(home: home, fs: fs, caskDatabase: caskDatabase, receipts: receipts, options: options)
    }

    // MARK: - Kimlik

    func makeIdentity(appURL: URL, bundleId: String?, appName: String) -> AppIdentity {
        let embedded = embeddedBundles(in: appURL)
        let signing = CodeSignatureReader.read(appPath: appURL.path)

        var groups: [String] = signing.appGroups
        var icloud: [String] = signing.icloudContainers
        for bundleURL in embedded.urls {
            let helperSigning = CodeSignatureReader.read(appPath: bundleURL.path)
            for g in helperSigning.appGroups where !groups.contains(g) { groups.append(g) }
            for c in helperSigning.icloudContainers where !icloud.contains(c) { icloud.append(c) }
        }

        return AppIdentity(
            name: appName,
            bundleId: bundleId,
            appPath: appURL.path,
            executableName: getExecutableName(from: appURL),
            embeddedBundleIds: embedded.ids,
            teamId: signing.teamId,
            appGroups: groups,
            icloudContainers: icloud,
            isSandboxed: signing.isSandboxed
        )
    }

    // MARK: - Tarama

    func buildItemsFast(appURL: URL, bundleId: String?, appName: String) -> [UninstallItem] {
        let identity = makeIdentity(appURL: appURL, bundleId: bundleId, appName: appName)
        let result = makeScanner().scanFast(identity: identity)
        return result.findings.compactMap(makeItem)
    }

    func buildItemsDeep(appURL: URL, bundleId: String?, appName: String) -> [UninstallItem] {
        let identity = makeIdentity(appURL: appURL, bundleId: bundleId, appName: appName)
        let result = makeScanner().scan(identity: identity)
        lastScanResult = result
        lastIdentity = identity
        return result.findings.compactMap(makeItem)
    }

    func buildItems(appURL: URL, bundleId: String?, appName: String) -> [UninstallItem] {
        buildItemsDeep(appURL: appURL, bundleId: bundleId, appName: appName)
    }

    private func makeItem(_ finding: Finding) -> UninstallItem? {
        let url = URL(fileURLWithPath: finding.path)
        guard fileManager.fileExists(atPath: finding.path) else { return nil }
        let strong = finding.strength == .strong
        return UninstallItem(
            url: url,
            displayName: url.lastPathComponent,
            kind: finding.kind,
            note: finding.note,
            sizeBytes: nil,
            isSelected: finding.isSelectedByDefault,
            isStrongMatch: strong,
            source: finding.source
        )
    }

    // MARK: - Rapor

    func describeSearchTerms(bundleId: String?, appName: String, appURL: URL) -> [String] {
        let identity = makeIdentity(appURL: appURL, bundleId: bundleId, appName: appName)
        var lines = SearchTerms(identity: identity).describe()
        lines.append("Team ID: " + (identity.teamId ?? "- (imzasız / ad-hoc)"))
        lines.append("Sandbox: " + (identity.isSandboxed ? "evet" : "hayır"))
        lines.append("App group'lar (entitlements): " + (identity.appGroups.isEmpty ? "-" : identity.appGroups.joined(separator: ", ")))
        if !identity.icloudContainers.isEmpty {
            lines.append("iCloud konteynerleri: " + identity.icloudContainers.joined(separator: ", "))
        }
        if !identity.embeddedBundleIds.isEmpty {
            lines.append("Gömülü yardımcı ID'leri: " + identity.embeddedBundleIds.joined(separator: ", "))
        }
        if let ids = lastScanResult?.receiptIds {
            lines.append("Kurulum paketleri (pkgutil): " + (ids.isEmpty ? "yok" : ids.joined(separator: ", ")))
        }
        lines.append("Sistem konumları (/Library): " + (includeSystemLocations ? "açık" : "kapalı"))
        lines.append("Geniş tarama: " + (includeAggressiveLocations ? "açık" : "kapalı"))
        lines.append(databaseDescription)
        if let tokens = lastScanResult?.caskTokens, !tokens.isEmpty {
            lines.append("Eşleşen cask: " + tokens.joined(separator: ", "))
        } else {
            lines.append("Eşleşen cask: yok")
        }
        return lines
    }

    func rawMentions(bundleId: String?, appName: String, appURL: URL, limit: Int = 300) -> (needles: [String], paths: [String]) {
        let identity = makeIdentity(appURL: appURL, bundleId: bundleId, appName: appName)
        return makeScanner().rawMentions(identity: identity, limit: limit)
    }

    /// Son taramadan test vakası üretir (Core/Tests/DustBusterCoreTests/Fixtures biçimi).
    func captureFixture(name: String) -> Fixture? {
        guard let result = lastScanResult, let identity = lastIdentity else { return nil }
        let mentions = makeScanner().rawMentions(identity: identity).paths
        return Fixture.capture(name: name, home: home, identity: identity, options: options,
                               result: result, rawMentions: mentions,
                               isDirectory: { fs.isRegularDirectory($0) },
                               isEmptyDirectory: { fs.isEffectivelyEmptyDirectory($0) },
                               containerIdentifier: { fs.containerIdentifier(ofContainerAt: $0) },
                               launchdProgram: { fs.launchdProgram(ofPlistAt: $0) })
    }

    // MARK: - Boyut

    /// Boyut hesabı. Home dışındaki yollar yalnızca uygulama paketi (/Applications/…app) veya
    /// /Library altı ise hesaplanır.
    func computeSizeBytes(for url: URL, isAppBundle: Bool = false) -> Int64? {
        let allowOutsideHome = isAppBundle || isInsideSystemLibrary(url) || url.path.hasPrefix("/Users/Shared/")
        return sizeOfItem(at: url, allowOutsideHome: allowOutsideHome)
    }

    private func sizeOfItem(at url: URL, allowOutsideHome: Bool) -> Int64? {
        let standardized = url.standardizedFileURL
        if !allowOutsideHome && !standardized.path.hasPrefix(home) {
            return nil
        }

        let keys: Set<URLResourceKey> = [
            .isDirectoryKey, .isSymbolicLinkKey,
            .totalFileAllocatedSizeKey, .fileAllocatedSizeKey, .totalFileSizeKey, .fileSizeKey
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
        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: Array(keys), options: [], errorHandler: nil) else { return 0 }
        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: keys) else { continue }
            if values.isSymbolicLink == true { continue }
            if values.isDirectory == true { continue }
            total += fileSize(from: values)
        }
        return total
    }

    private func fileSize(from values: URLResourceValues) -> Int64 {
        if let allocated = values.totalFileAllocatedSize, allocated > 0 { return Int64(allocated) }
        if let allocated = values.fileAllocatedSize, allocated > 0 { return Int64(allocated) }
        if let size = values.totalFileSize { return Int64(size) }
        if let size = values.fileSize { return Int64(size) }
        return 0
    }

    // MARK: - Yardımcılar

    private func isInsideSystemLibrary(_ url: URL) -> Bool {
        let path = url.standardizedFileURL.path
        return path.hasPrefix("/Library/") && !path.hasPrefix("/Library/Apple")
    }

    private func getExecutableName(from appURL: URL) -> String? {
        let plistURL = appURL.appendingPathComponent("Contents/Info.plist")
        guard let plistData = try? Data(contentsOf: plistURL),
              let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else {
            return nil
        }
        return plist["CFBundleExecutable"] as? String
    }

    /// Paket içindeki yardımcı uygulamalar (LoginItems, LaunchServices, Helpers, XPC, appex): bundle ID'leri ve yolları.
    private func embeddedBundles(in appURL: URL) -> (ids: [String], urls: [URL]) {
        let helperPaths = [
            "Contents/Library/LoginItems",
            "Contents/Library/LaunchServices",
            "Contents/Helpers",
            "Contents/XPCServices",
            "Contents/PlugIns",
            "Contents/Frameworks"
        ]
        var ids: [String] = []
        var urls: [URL] = []
        for helperPath in helperPaths {
            let dir = appURL.appendingPathComponent(helperPath)
            guard let contents = try? fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else { continue }
            for itemURL in contents {
                let ext = itemURL.pathExtension.lowercased()
                guard ["app", "xpc", "appex"].contains(ext) else { continue }
                if let id = Bundle(url: itemURL)?.bundleIdentifier, !id.isEmpty, !ids.contains(id) {
                    ids.append(id)
                    urls.append(itemURL)
                }
            }
        }
        return (ids, urls)
    }
}

// MARK: - Kod imzası ve entitlements

/// Security çerçevesiyle paketin imza bilgisini okur: Team ID, app group'lar, iCloud konteynerleri, sandbox.
/// İmzasız/ad-hoc paketlerde Team ID boş döner; entitlements yine okunabilir.
struct CodeSignatureReader {
    struct Info {
        var teamId: String?
        var appGroups: [String] = []
        var icloudContainers: [String] = []
        var isSandboxed: Bool = false
    }

    static func read(appPath: String) -> Info {
        var info = Info()
        var staticCode: SecStaticCode?
        let url = URL(fileURLWithPath: appPath) as CFURL
        guard SecStaticCodeCreateWithPath(url, SecCSFlags(), &staticCode) == errSecSuccess, let code = staticCode else {
            return info
        }

        var signingInfo: CFDictionary?
        let flags = SecCSFlags(rawValue: kSecCSSigningInformation | kSecCSRequirementInformation)
        guard SecCodeCopySigningInformation(code, flags, &signingInfo) == errSecSuccess,
              let dict = signingInfo as? [String: Any] else {
            return info
        }

        if let team = dict[kSecCodeInfoTeamIdentifier as String] as? String, !team.isEmpty {
            info.teamId = team
        }
        if let entitlements = dict[kSecCodeInfoEntitlementsDict as String] as? [String: Any] {
            if let groups = entitlements["com.apple.security.application-groups"] as? [String] {
                info.appGroups = groups.filter { !$0.isEmpty }
            }
            if let containers = entitlements["com.apple.developer.icloud-container-identifiers"] as? [String] {
                info.icloudContainers = containers.filter { !$0.isEmpty }
            }
            if let sandbox = entitlements["com.apple.security.app-sandbox"] as? Bool {
                info.isSandboxed = sandbox
            }
        }
        return info
    }
}

// MARK: - pkgutil

/// `/usr/sbin/pkgutil` üzerinden kurulum faturaları. Çıktılar tarama başına önbelleğe alınır.
final class PkgutilReceiptProvider: ReceiptProvider {
    private let queue = DispatchQueue(label: "DustBuster.pkgutil")
    private var cachedIds: [String]?
    private var cachedFiles: [String: [String]] = [:]

    func installedPackageIds() -> [String] {
        queue.sync {
            if let ids = cachedIds { return ids }
            let output = run(["--pkgs"]) ?? ""
            let ids = output.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            cachedIds = ids
            return ids
        }
    }

    func files(forPackage id: String) -> [String] {
        queue.sync {
            if let cached = cachedFiles[id] { return cached }
            // Kurulum konumu: "volume: /" + "location: Applications" gibi
            var volume = "/"
            var location = ""
            if let info = run(["--pkg-info", id]) {
                for line in info.split(separator: "\n") {
                    let parts = line.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
                    guard parts.count == 2 else { continue }
                    if parts[0] == "volume" { volume = parts[1] }
                    if parts[0] == "location" { location = parts[1] }
                }
            }
            var base = volume.hasSuffix("/") ? String(volume.dropLast()) : volume
            if !location.isEmpty { base += "/" + location }
            let listing = run(["--files", id]) ?? ""
            let files = listing.split(separator: "\n").map { String($0) }.filter { !$0.isEmpty }.map { base + "/" + $0 }
            cachedFiles[id] = files
            return files
        }
    }

    private func run(_ arguments: [String]) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/pkgutil")
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
        } catch {
            return nil
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
