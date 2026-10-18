// Sources/Views/SidebarView.swift
import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarItem?

    var body: some View {
        List(selection: $selection) {
            Section("Genel") {
                NavigationLink(value: SidebarItem.dashboard) {
                    Label("Panel", systemImage: "gauge")
                        .font(.body)
                }
            }

            Section("Araçlar") {
                NavigationLink(value: SidebarItem.processes) {
                    Label("Çalışan Uygulamalar", systemImage: "rectangle.stack.person.crop")
                        .font(.body)
                }

                NavigationLink(value: SidebarItem.largeFiles) {
                    Label("Büyük Dosyalar", systemImage: "externaldrive")
                        .font(.body)
                }

                NavigationLink(value: SidebarItem.uninstaller) {
                    Label("Uygulama Kaldır", systemImage: "trash.slash")
                        .font(.body)
                }

                NavigationLink(value: SidebarItem.settings) {
                    Label("Ayarlar", systemImage: "gearshape")
                        .font(.body)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 220, ideal: 240, max: 280)
    }
}
