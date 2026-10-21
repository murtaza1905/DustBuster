// Sources/Managers/ReportExporter.swift

import Foundation
import AppKit
import UniformTypeIdentifiers

/// .txt rapor dışa aktarımı için ortak yardımcılar (Uygulama Kaldır + Sistem Temizliği).
/// Raporlar yalnızca kullanıcının seçtiği konuma yazılır; otomatik gönderim yoktur.
enum ReportExporter {
    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let fileNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// Rapor başlığı: tarih, uygulama sürümü, macOS sürümü, işlemci.
    static func headerLines(title: String) -> [String] {
        let info = ProcessInfo.processInfo
        let os = info.operatingSystemVersion
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        #if arch(arm64)
        let chip = "Apple Silicon"
        #else
        let chip = "Intel"
        #endif
        return [
            "DustBuster — \(title)",
            "Tarih: \(timestampFormatter.string(from: Date()))",
            "DustBuster: \(version) (\(build))",
            "macOS: \(os.majorVersion).\(os.minorVersion).\(os.patchVersion) (\(chip))",
            ""
        ]
    }

    static func suggestedFileName(prefix: String) -> String {
        "\(prefix)_\(fileNameFormatter.string(from: Date())).txt"
    }

    static func formatSize(_ bytes: Int64?) -> String {
        guard let bytes else { return "-" }
        return bytes == 0 ? "boş" : ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }

    /// Home dizinini "~" ile kısaltır.
    static func tildePath(_ path: String) -> String {
        let home = NSHomeDirectory()
        guard path.hasPrefix(home) else { return path }
        return "~" + String(path.dropFirst(home.count))
    }

    /// Kaydet penceresi açar ve metni seçilen konuma yazar. Ana iş parçacığında çağrılmalı.
    /// Kullanıcı vazgeçerse completion çağrılmaz.
    static func save(text: String, suggestedName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = suggestedName
        panel.allowedContentTypes = [.plainText]
        panel.isExtensionHidden = false
        panel.canCreateDirectories = true
        panel.message = "Rapor yalnızca bu cihaza kaydedilir."
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            do {
                try text.write(to: url, atomically: true, encoding: .utf8)
                completion(.success(url))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
