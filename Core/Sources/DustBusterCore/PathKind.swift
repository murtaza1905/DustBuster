import Foundation

/// Kalıntının bulunduğu konum türü. Ham değerler arayüzde etiket olarak gösterilir.
public enum LeftoverKind: String, Codable, CaseIterable {
    case appBundle = "Uygulama Paketi"
    case applicationSupport = "Application Support"
    case caches = "Caches"
    case preferences = "Preferences"
    case preferencesByHost = "Preferences (ByHost)"
    case logs = "Logs"
    case savedState = "Saved Application State"
    case containers = "Containers"
    case groupContainers = "Group Containers"
    case launchAgents = "Launch Agents"
    case httpStorages = "HTTP Storages"
    case webKit = "WebKit"
    case cookies = "Cookies"
    case crashReports = "Crash Reports"
    case applicationScripts = "Application Scripts"
    case internetPlugins = "Internet Plug-Ins"
    case preferencePanes = "Preference Panes"
    case quickLook = "QuickLook"
    case screenSavers = "Screen Savers"
    case services = "Services"
    case spotlight = "Spotlight"
    case inputMethods = "Input Methods"
    case frameworks = "Frameworks"
    case colorPickers = "Color Pickers"
    case addressBookPlugins = "Address Book Plug-Ins"
    case mailBundles = "Mail Bundles"
    case developer = "Developer"
    case recentDocuments = "Recent Documents"
    case systemAppSupport = "System Application Support"
    case systemLaunchAgents = "System Launch Agents"
    case systemLaunchDaemons = "System Launch Daemons"
    case privilegedHelpers = "Privileged Helper Tools"
    case systemPreferences = "System Preferences"
    case systemFrameworks = "System Frameworks"
    case systemLogs = "System Logs"
    case systemCaches = "System Caches"
    case homeDotfile = "Ev Dizini (gizli)"
    case sharedUsers = "Paylaşılan (/Users/Shared)"
    case other = "Diğer"
}

public enum PathClassifier {
    /// ~/Library ve /Library altındaki yolları konum türüne çevirir.
    public static func kind(forPath path: String, home: String) -> LeftoverKind {
        let userLib = home + "/Library/"
        let sysLib = "/Library/"

        if path.hasPrefix(userLib) {
            let rel = String(path.dropFirst(userLib.count))
            let top = rel.split(separator: "/").first.map(String.init) ?? ""
            if rel.hasPrefix("Preferences/ByHost/") { return .preferencesByHost }
            if rel.hasPrefix("Logs/DiagnosticReports/") || rel.hasPrefix("Logs/CrashReporter/") { return .crashReports }
            if rel.hasPrefix("Application Support/CrashReporter/") { return .crashReports }
            if rel.hasPrefix("Application Support/com.apple.sharedfilelist/") { return .recentDocuments }
            switch top {
            case "Application Support": return .applicationSupport
            case "Caches": return .caches
            case "Preferences": return .preferences
            case "Logs": return .logs
            case "Saved Application State": return .savedState
            case "Containers": return .containers
            case "Group Containers": return .groupContainers
            case "LaunchAgents": return .launchAgents
            case "HTTPStorages": return .httpStorages
            case "WebKit": return .webKit
            case "Cookies": return .cookies
            case "Application Scripts": return .applicationScripts
            case "Internet Plug-Ins": return .internetPlugins
            case "PreferencePanes": return .preferencePanes
            case "QuickLook": return .quickLook
            case "Screen Savers": return .screenSavers
            case "Services": return .services
            case "Spotlight": return .spotlight
            case "Input Methods": return .inputMethods
            case "Frameworks": return .frameworks
            case "ColorPickers": return .colorPickers
            case "Address Book Plug-Ins": return .addressBookPlugins
            case "Mail": return .mailBundles
            case "Developer": return .developer
            default: return .other
            }
        }

        if path.hasPrefix(sysLib) {
            let rel = String(path.dropFirst(sysLib.count))
            let top = rel.split(separator: "/").first.map(String.init) ?? ""
            switch top {
            case "Application Support": return .systemAppSupport
            case "LaunchAgents": return .systemLaunchAgents
            case "LaunchDaemons": return .systemLaunchDaemons
            case "PrivilegedHelperTools": return .privilegedHelpers
            case "Preferences": return .systemPreferences
            case "Frameworks": return .systemFrameworks
            case "Logs": return .systemLogs
            case "Caches": return .systemCaches
            default: return .other
            }
        }

        if path.hasPrefix(home + "/.") { return .homeDotfile }
        if path.hasPrefix("/Users/Shared/") { return .sharedUsers }
        return .other
    }

    /// Kullanıcı verisi taşıyan, kaldırma listesine ASLA girmeyecek ~/Library kökleri.
    public static let protectedUserLibraryRoots: Set<String> = [
        "Keychains", "Mobile Documents", "CloudStorage", "Mail", "Messages", "Accounts",
        "Safari", "Photos", "Calendars", "Reminders", "Contacts", "Passes", "Suggestions"
    ]

    /// Kaldırma işleminde bir yolun kabul edilip edilmeyeceğine ve nasıl etiketleneceğine karar verir.
    public enum Admission: Equatable {
        case accepted(MatchStrength, note: String?)
        case rejected(reason: String)
    }

    public static func admit(path: String, home: String, options: ScanOptions) -> Admission {
        let userLib = home + "/Library/"
        if path.hasPrefix(userLib) {
            let top = path.dropFirst(userLib.count).split(separator: "/").first.map(String.init) ?? ""
            if protectedUserLibraryRoots.contains(top) {
                return .rejected(reason: "korunan kullanıcı verisi: ~/Library/\(top)")
            }
            return .accepted(.strong, note: nil)
        }
        if path.hasPrefix("/Library/") {
            if path.hasPrefix("/Library/Apple/") { return .rejected(reason: "Apple sistem alanı") }
            guard options.includeSystemLocations else {
                return .rejected(reason: "sistem konumu (/Library) — 'Sistem dosyalarını da tara' kapalı")
            }
            return .accepted(.strong, note: "admin yetkisi gerekebilir")
        }
        if path.hasPrefix(home + "/.") {
            return .accepted(.weak, note: "ev dizininde gizli klasör — kontrol et")
        }
        if path.hasPrefix("/Users/Shared/") {
            return .accepted(.weak, note: "tüm kullanıcılara ortak — kontrol et")
        }
        if path.hasPrefix("/Applications/") || path.hasPrefix(home + "/Applications/") {
            // Yalnızca veritabanı buraya yol önerir (ör. sürücü kurucu .bundle); .app paketleri kabul edilmez
            if path.lowercased().hasSuffix(".app") {
                return .rejected(reason: "başka bir uygulama paketi")
            }
            return .accepted(.strong, note: "Uygulamalar klasöründe ek bileşen")
        }
        if path.hasPrefix(home + "/") {
            return .rejected(reason: "kullanıcı verisi (Belgeler, Masaüstü vb.)")
        }
        return .rejected(reason: "kapsam dışı kök")
    }
}
