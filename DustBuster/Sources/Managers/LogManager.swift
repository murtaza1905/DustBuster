// Sources/Managers/LogManager.swift
import Foundation
import OSLog
import AppKit
import UniformTypeIdentifiers

/// Privacy-first logging helper that keeps everything on-device.
final class LogManager {
    static let shared = LogManager()
    
    enum Category: String, CaseIterable {
        case audit
        case cleanup
        case error
        case performance
    }
    
    enum Level: String {
        case debug
        case info
        case warning
        case error
        case fault
    }
    
    private let subsystem: String
    private var loggers: [Category: Logger] = [:]
    private var exportDateFormatter: DateFormatter
    private var timestampFormatter: DateFormatter
    
    private init() {
        // 1. Initialize all stored properties first
        subsystem = Bundle.main.bundleIdentifier ?? "DustBuster"
        
        exportDateFormatter = DateFormatter()
        timestampFormatter = DateFormatter()
        
        // 2. Now we can use self - configure formatters
        exportDateFormatter.dateFormat = "yyyy-MM-dd"
        exportDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        timestampFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        timestampFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // 3. Populate loggers using for-in loop (not forEach closure)
        for category in Category.allCases {
            loggers[category] = Logger(subsystem: subsystem, category: category.rawValue)
        }
    }
    
    // MARK: - Public API
    
    func log(_ message: String, category: Category, level: Level) {
        guard let logger = loggers[category] else { return }
        
        let sanitized = sanitize(message)
        switch level {
        case .debug:
            logger.debug("\(sanitized, privacy: .public)")
        case .info:
            logger.info("\(sanitized, privacy: .public)")
        case .warning:
            logger.warning("\(sanitized, privacy: .public)")
        case .error:
            logger.error("\(sanitized, privacy: .public)")
        case .fault:
            logger.fault("\(sanitized, privacy: .public)")
        }
    }
    
    @MainActor
    func exportLogs() {
        let savePanel = NSSavePanel()
        let today = exportDateFormatter.string(from: Date())
        savePanel.nameFieldStringValue = "DustBuster_Logs_\(today).txt"
        savePanel.allowedContentTypes = [.plainText]
        savePanel.isExtensionHidden = false
        savePanel.canCreateDirectories = true
        savePanel.message = "Son 7 günün uygulama loglarını cihazında kaydet."
        
        savePanel.begin { [weak self] response in
            guard
                response == .OK,
                let url = savePanel.url,
                let self = self
            else { return }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let content = self.buildExportContent()
                do {
                    try content.write(to: url, atomically: true, encoding: .utf8)
                    self.log("Log export completed", category: .audit, level: .info)
                } catch {
                    let nsError = error as NSError
                    self.log("Log export failed code \(nsError.code)", category: .error, level: .error)
                }
            }
        }
    }
    
    // MARK: - Export helpers
    
    private func buildExportContent() -> String {
        var lines: [String] = []
        
        lines.append("DustBuster Log Export")
        lines.append("Oluşturulma: \(timestampFormatter.string(from: Date()))")
        lines.append("")
        lines.append("Sistem Bilgileri")
        systemInformation().forEach { key, value in
            lines.append("- \(key): \(value)")
        }
        
        lines.append("")
        lines.append("Son 7 Gün Logları")
        
        let logs = fetchRecentLogs()
        if logs.isEmpty {
            lines.append("Kayıt bulunamadı.")
        } else {
            logs.forEach { entry in
                let dateText = timestampFormatter.string(from: entry.date)
                let levelText = string(for: entry.level)
                let sanitizedMessage = sanitize(entry.composedMessage)
                lines.append("\(dateText) [\(entry.category)] [\(levelText)] \(sanitizedMessage)")
            }
        }
        
        lines.append("")
        lines.append("Gizlilik Notu: DustBuster logları sadece bu cihazda tutulur; IP adresi, MAC adresi, kullanıcı adı veya dosya yolları kaydedilmez.")
        
        return lines.joined(separator: "\n")
    }
    
    private func fetchRecentLogs() -> [OSLogEntryLog] {
        do {
            let store = try OSLogStore.local()
            let sevenDaysAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
            let position = store.position(date: sevenDaysAgo)
            let predicate = NSPredicate(format: "subsystem == %@", subsystem)
            let entries = try store.getEntries(at: position, matching: predicate)
            
            return entries.compactMap { $0 as? OSLogEntryLog }
        } catch {
            let nsError = error as NSError
            log("Log store read failed code \(nsError.code)", category: .error, level: .error)
            return []
        }
    }
    
    // MARK: - System info
    
    private func systemInformation() -> [(String, String)] {
        let processInfo = ProcessInfo.processInfo
        let osVersion = processInfo.operatingSystemVersion
        
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Bilinmiyor"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Bilinmiyor"
        
        let macOSVersion = "macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        let chip = chipType()
        let memory = ByteCountFormatter.string(fromByteCount: Int64(processInfo.physicalMemory), countStyle: .binary)
        
        return [
            ("macOS Sürümü", macOSVersion),
            ("Uygulama Sürümü", appVersion),
            ("Build Numarası", buildNumber),
            ("Chip", chip),
            ("RAM", memory)
        ]
    }
    
    private func chipType() -> String {
        #if arch(arm64)
        return "Apple Silicon"
        #else
        return "Intel"
        #endif
    }
    
    // MARK: - Sanitization
    
    /// Removes user-identifiable data such as usernames, hostnames, IP/MAC addresses and home paths.
    private func sanitize(_ message: String) -> String {
        var sanitized = message
        
        let homePath = NSHomeDirectory()
        if !homePath.isEmpty {
            sanitized = sanitized.replacingOccurrences(of: homePath, with: "[REDACTED_HOME]")
        }
        
        let username = NSUserName()
        if !username.isEmpty {
            sanitized = sanitized.replacingOccurrences(of: username, with: "[REDACTED_USER]")
        }
        
        let fullUsername = NSFullUserName()
        if !fullUsername.isEmpty {
            sanitized = sanitized.replacingOccurrences(of: fullUsername, with: "[REDACTED_USER]")
        }
        
        let hostName = ProcessInfo.processInfo.hostName
        if !hostName.isEmpty {
            sanitized = sanitized.replacingOccurrences(of: hostName, with: "[REDACTED_HOST]")
        }
        
        if let localizedHost = Host.current().localizedName {
            sanitized = sanitized.replacingOccurrences(of: localizedHost, with: "[REDACTED_HOST]")
        }
        
        sanitized = redact(pattern: #"\b(?:\d{1,3}\.){3}\d{1,3}\b"#, in: sanitized, placeholder: "[REDACTED_IP]")
        sanitized = redact(pattern: #"\b(?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\b"#, in: sanitized, placeholder: "[REDACTED_MAC]")
        sanitized = sanitized.replacingOccurrences(of: "localhost", with: "[REDACTED_HOST]")
        
        return sanitized
    }
    
    private func redact(pattern: String, in text: String, placeholder: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text
        }
        
        let range = NSRange(text.startIndex..., in: text)
        return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: placeholder)
    }
    
    // MARK: - Helpers
    
    private func string(for level: OSLogEntryLog.Level) -> String {
        switch level {
        case .undefined:
            return "undefined"
        case .debug:
            return "debug"
        case .info:
            return "info"
        case .notice:
            return "notice"
        case .error:
            return "error"
        case .fault:
            return "fault"
        @unknown default:
            return "unknown"
        }
    }
}
