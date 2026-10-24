import SwiftUI

@main
struct DustBusterApp: App {
    @StateObject private var permissionVM = AppPermissionViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(permissionVM)
        }
        .windowToolbarStyle(.unified)
        .commands {
            SidebarCommands()
        }
    }
}
