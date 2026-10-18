// Sources/App/ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var selection: SidebarItem? = .dashboard
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @StateObject private var largeFilesViewModel = LargeFilesViewModel()

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selection: $selection)
        } detail: {
            MainDetailRouter(selection: selection)
                .environmentObject(largeFilesViewModel)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 800, minHeight: 600)
    }
}
