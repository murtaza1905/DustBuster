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
    /// Kod imzasından Team ID (Tur B)
    public var teamId: String?
    /// Entitlements'tan app group ID'leri (Tur B)
    public var appGroups: [String]

    public init(
        name: String,
        bundleId: String?,
        appPath: String,
        executableName: String? = nil,
        embeddedBundleIds: [String] = [],
        teamId: String? = nil,
        appGroups: [String] = []
    ) {
        self.name = name
        self.bundleId = bundleId
        self.appPath = appPath
        self.executableName = executableName
        self.embeddedBundleIds = embeddedBundleIds
        self.teamId = teamId
        self.appGroups = appGroups
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
