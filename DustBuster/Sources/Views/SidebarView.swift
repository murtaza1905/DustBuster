import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarItem?

    var body: some View {
        List(selection: $selection) {
            Section("Genel") {
                row(.dashboard)
            }
            Section("Araçlar") {
                row(.processes)
                row(.largeFiles)
                row(.uninstaller)
            }
            Section {
                row(.settings)
            }
        }
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 200, ideal: 230, max: 280)
    }

    private func row(_ item: SidebarItem) -> some View {
        NavigationLink(value: item) {
            Label(item.title, systemImage: item.systemImage)
                .symbolRenderingMode(.hierarchical)
        }
    }
}
