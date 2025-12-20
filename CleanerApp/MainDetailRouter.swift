import SwiftUI

struct MainDetailRouter: View {
    let selection: SidebarItem?
    
    var body: some View {
        switch selection ?? .dashboard {
        case .dashboard:
            PermissionGate(requiresFullDiskAccess: true) {
                DashboardView()
            }
        case .processes:
            PermissionGate(requiresFullDiskAccess: true) {
                ProcessListView()
            }
        case .largeFiles:
            PermissionGate(requiresFullDiskAccess: true) {
                LargeFilesView()
            }
        case .uninstaller:
            PermissionGate(requiresFullDiskAccess: true) {
                UninstallerView()
            }
        case .settings:
            PermissionGate(requiresFullDiskAccess: false) {
                SettingsView()
            }
        }
    }
}
