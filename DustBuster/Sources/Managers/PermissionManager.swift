import Foundation
import AppKit
import SwiftUI
import Combine

/// Manages File System Permissions (Full Disk Access).
final class PermissionManager: ObservableObject {

    // MARK: - Singleton

    static let shared = PermissionManager()

    @Published var hasFullDiskAccess: Bool = false
    private let logManager = LogManager.shared

    private init() {
        checkFullDiskAccess()
    }
    
    /// Checks if the app has Full Disk Access.
    /// It attempts to read a protected path to verify FDA.
    func checkFullDiskAccess() {
        let fm = FileManager.default
        let home = fm.homeDirectoryForCurrentUser
        
        let testPaths: [URL] = [
            URL(fileURLWithPath: "/private/var/log"),
            home.appendingPathComponent("Library/Mail"),
            home.appendingPathComponent("Library/Messages"),
            home.appendingPathComponent("Library/Calendars"),
            home.appendingPathComponent("Library/Safari")
        ]
        
        var anyTestExecuted = false
        var hasAccess = true
        
        for url in testPaths {
            let path = url.path
            guard fm.fileExists(atPath: path) else { continue }
            anyTestExecuted = true
            
            do {
                _ = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                #if DEBUG
                print("FDA check succeeded for \(path)")
                #endif
            } catch {
                #if DEBUG
                print("FDA check failed for \(path): \(error.localizedDescription)")
                #endif
                hasAccess = false
                break
            }
        }
        
        if !anyTestExecuted {
            hasAccess = false
        }
        
        DispatchQueue.main.async {
            self.hasFullDiskAccess = hasAccess
            let level: LogManager.Level = hasAccess ? .info : .warning
            self.logManager.log("Full Disk Access durumu: \(hasAccess ? "var" : "yok")", category: .audit, level: level)
        }
    }
    
    /// Opens the System Settings pane for Full Disk Access.
    func requestFullDiskAccess() {
        PermissionManager.openFullDiskAccessSettings()
    }

    static func openFullDiskAccessSettings() {
        // macOS Ventura+ URL scheme
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}
