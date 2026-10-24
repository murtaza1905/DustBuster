import Foundation

enum SidebarItem: Hashable, CaseIterable {
    case dashboard
    case processes
    case largeFiles
    case uninstaller
    case settings

    var title: String {
        switch self {
        case .dashboard: return "Panel"
        case .processes: return "Çalışan Uygulamalar"
        case .largeFiles: return "Büyük Dosyalar"
        case .uninstaller: return "Uygulama Kaldır"
        case .settings: return "Ayarlar"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: return "gauge.with.dots.needle.33percent"
        case .processes: return "rectangle.stack.badge.person.crop"
        case .largeFiles: return "externaldrive"
        case .uninstaller: return "trash.slash"
        case .settings: return "gearshape"
        }
    }
}
