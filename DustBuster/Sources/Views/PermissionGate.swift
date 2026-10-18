import SwiftUI

struct PermissionGate<Content: View>: View {
    @EnvironmentObject var permissionVM: AppPermissionViewModel
    
    let requiresFullDiskAccess: Bool
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        if requiresFullDiskAccess, !permissionVM.hasFullDiskAccess {
            FullDiskAccessLockedView()
        } else {
            content()
        }
    }
}
