import SwiftUI

@main
struct CleanAppApp: App {
    @StateObject private var permissionVM = AppPermissionViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(permissionVM)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            SidebarCommands()
        }
    }
}
