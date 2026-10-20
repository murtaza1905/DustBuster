// Sources/Managers/UninstallerManager.swift

import Foundation
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
        LeftoverScanner(home: home, fs: fs, caskDatabase: caskDatabase, options: options)
    }

    // MARK: - Kimlik

    func makeIdentity(appURL: URL, bundleId: String?, appName: String) -> AppIdentity {
        AppIdentity(
            name: appName,
            bundleId: bundleId,
            appPath: appURL.path,
            executableName: getExecutableName(from: appURL),
            embeddedBundleIds: embeddedBundleIdentifiers(in: appURL)
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
        if !identity.embeddedBundleIds.isEmpty {
            lines.append("Gömülü yardımcı ID'leri: " + identity.embeddedBundleIds.joined(separator: ", "))
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
                               isEmptyDirectory: { fs.isEffectivelyEmptyDirectory($0) })
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

    /// Paket içindeki yardımcı uygulamaların (LoginItems, LaunchServices, Helpers, XPC, appex) bundle ID'leri.
    private func embeddedBundleIdentifiers(in appURL: URL) -> [String] {
        let helperPaths = [
            "Contents/Library/LoginItems",
            "Contents/Library/LaunchServices",
            "Contents/Helpers",
            "Contents/XPCServices",
            "Contents/PlugIns",
            "Contents/Frameworks"
        ]
        var ids: [String] = []
        for helperPath in helperPaths {
            let dir = appURL.appendingPathComponent(helperPath)
            guard let contents = try? fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else { continue }
            for itemURL in contents {
                let ext = itemURL.pathExtension.lowercased()
                guard ["app", "xpc", "appex"].contains(ext) else { continue }
                if let id = Bundle(url: itemURL)?.bundleIdentifier, !id.isEmpty, !ids.contains(id) {
                    ids.append(id)
                }
            }
        }
        return ids
    }
}
