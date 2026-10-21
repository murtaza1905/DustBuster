import Foundation

/// Kaldırılacak uygulamanın tarama için gereken kimliği. Uygulama katmanı bunu
/// Info.plist, kod imzası ve gömülü paketlerden doldurur; çekirdek yalnızca bu yapıya bakar.
public struct AppIdentity: Codable, Equatable {
    public var name: String
    public var bundleId: String?
    public var appPath: String
    /// Info.plist CFBundleExecutable
    public var executableName: String?
    /// Paket içindeki yardımcıların (LoginItems, XPC, appex, Helpers) bundle ID'leri
    public var embeddedBundleIds: [String]
    /// Kod imzasından Team ID
    public var teamId: String?
    /// Entitlements'tan app group ID'leri (uygulama + gömülü yardımcılar)
    public var appGroups: [String]
    /// Entitlements'tan iCloud konteyner ID'leri
    public var icloudContainers: [String]
    /// com.apple.security.app-sandbox
    public var isSandboxed: Bool
    /// Diskteki kurulum faturalarından (pkgutil) uygulamaya ait paket kimlikleri
    public var receiptIds: [String]

    public init(
        name: String,
        bundleId: String?,
        appPath: String,
        executableName: String? = nil,
        embeddedBundleIds: [String] = [],
        teamId: String? = nil,
        appGroups: [String] = [],
        icloudContainers: [String] = [],
        isSandboxed: Bool = false,
        receiptIds: [String] = []
    ) {
        self.name = name
        self.bundleId = bundleId
        self.appPath = appPath
        self.executableName = executableName
        self.embeddedBundleIds = embeddedBundleIds
        self.teamId = teamId
        self.appGroups = appGroups
        self.icloudContainers = icloudContainers
        self.isSandboxed = isSandboxed
        self.receiptIds = receiptIds
    }

    enum CodingKeys: String, CodingKey {
        case name, bundleId, appPath, executableName, embeddedBundleIds, teamId, appGroups, icloudContainers, isSandboxed, receiptIds
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        bundleId = try c.decodeIfPresent(String.self, forKey: .bundleId)
        appPath = try c.decode(String.self, forKey: .appPath)
        executableName = try c.decodeIfPresent(String.self, forKey: .executableName)
        embeddedBundleIds = try c.decodeIfPresent([String].self, forKey: .embeddedBundleIds) ?? []
        teamId = try c.decodeIfPresent(String.self, forKey: .teamId)
        appGroups = try c.decodeIfPresent([String].self, forKey: .appGroups) ?? []
        icloudContainers = try c.decodeIfPresent([String].self, forKey: .icloudContainers) ?? []
        isSandboxed = try c.decodeIfPresent(Bool.self, forKey: .isSandboxed) ?? false
        receiptIds = try c.decodeIfPresent([String].self, forKey: .receiptIds) ?? []
    }

    /// "/Applications/Google Chrome.app" → "Google Chrome.app"
    public var appFileName: String {
        (appPath as NSString).lastPathComponent
    }

    /// "Google Chrome.app" → "Google Chrome"
    public var appFileStem: String {
        (appFileName as NSString).deletingPathExtension
    }

    public var isAppleApp: Bool {
        bundleId?.lowercased().hasPrefix("com.apple.") ?? false
    }

    public var isSystemApp: Bool {
        appPath == "/System" || appPath.hasPrefix("/System/")
    }
}

/// Tarama seçenekleri.
public struct ScanOptions: Equatable {
    public var includeSystemLocations: Bool
    public var includeAggressiveLocations: Bool
    public var useCaskDatabase: Bool
    /// Bu sayının üzerinde sonuç dönerse derin tarama sonuçları atılır.
    public var maxReasonableResults: Int

    public init(
        includeSystemLocations: Bool = false,
        includeAggressiveLocations: Bool = false,
        useCaskDatabase: Bool = true,
        maxReasonableResults: Int = 100
    ) {
        self.includeSystemLocations = includeSystemLocations
        self.includeAggressiveLocations = includeAggressiveLocations
        self.useCaskDatabase = useCaskDatabase
        self.maxReasonableResults = maxReasonableResults
    }
}
