// Sources/Managers/ProcessManager.swift
import Foundation
import Combine
import AppKit

/// Çalışan uygulamaları listeler ve güvenli şekilde sonlandırır.
class ProcessManager: ObservableObject {
    @Published var processes: [ProcessItem] = []
    private let logManager = LogManager.shared

    /// Kill edilmemesi gereken kritik sistem uygulamaları.
    private let protectedBundleIDs: Set<String> = [
        "com.apple.Finder",
        "com.apple.dock",
        "com.apple.WindowServer",
        "com.apple.loginwindow"
    ]

    /// Çalışan uygulamaları yenile.
    func refresh() {
        let running = NSWorkspace.shared.runningApplications
        let currentPID = ProcessInfo.processInfo.processIdentifier

        var items: [ProcessItem] = []

        for app in running {
            // Uygulama adı yoksa geç
            guard let name = app.localizedName else { continue }

            // Sadece normal kullanıcı uygulamaları (Dock’ta görünenler)
            guard app.activationPolicy == .regular else { continue }

            let bundleID = app.bundleIdentifier

            // Bu temizlik uygulamasını ve korunacak sistem app’lerini hiç listeleme
            let isCurrentApp = app.processIdentifier == currentPID
            let isProtectedBundle = bundleID.map { protectedBundleIDs.contains($0) } ?? false
            if isCurrentApp || isProtectedBundle {
                continue
            }

            // Xcode gibi com.apple.* GUI uygulamaları burada kalır (görünür)
            let item = ProcessItem(
                pid: Int(app.processIdentifier),
                name: name,
                bundleIdentifier: bundleID,
                isSystemProtected: false   // Listeye girenlerin hepsi kapatılabilir
            )
            items.append(item)
        }

        // Varsayılan: ada göre A–Z
        items.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        DispatchQueue.main.async {
            self.processes = items
            self.logManager.log("Process listesi güncellendi: \(items.count) uygulama", category: .audit, level: .info)
        }
    }

    /// Uygulamayı sonlandır (force = true ise zorla sonlandır).
    func terminate(_ process: ProcessItem, force: Bool = false) {
        // Ek güvenlik: ileride isSystemProtected kullanılırsa diye bırakıyoruz.
        guard !process.isSystemProtected else { return }
        
        logManager.log("Uygulama kapatma isteği alındı, PID \(process.pid)", category: .audit, level: .warning)

        let running = NSWorkspace.shared.runningApplications
        if let app = running.first(where: { Int($0.processIdentifier) == process.pid }) {
            if force {
                _ = app.forceTerminate()
            } else {
                _ = app.terminate()
            }
        }

        // Listeden kaldır
        DispatchQueue.main.async {
            self.processes.removeAll { $0.pid == process.pid }
        }
    }
}
