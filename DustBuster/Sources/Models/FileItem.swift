import Foundation

/// Represents a file or folder identified for cleaning.
struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let size: Int64
    let isDirectory: Bool

    // UI Properties
    var isSelected: Bool = true

    var path: String {
        return url.path
    }

    var name: String {
        return url.lastPathComponent
    }

    var displayName: String {
        // MARK: - Safari Cache (dizin sınırına saygılı: com.apple.Safari.SafeBrowsing buraya girmez)
        if path.contains("/com.apple.Safari/") || path.hasSuffix("/com.apple.Safari") {
            if path.contains("WebKitCache") {
                return "Safari WebKit Cache"
            }
            return "Safari Cache"
        }

        // MARK: - Gecko Tabanlı Tarayıcılar (Firefox Ailesi)
        if path.contains("/Caches/Firefox/Profiles/") && path.contains("/cache2") {
            return "Firefox Cache"
        }
        if path.contains("/Caches/LibreWolf/Profiles/") && path.contains("/cache2") {
            return "LibreWolf Cache"
        }
        if path.contains("/Caches/Waterfox/Profiles/") && path.contains("/cache2") {
            return "Waterfox Cache"
        }
        if path.contains("/Caches/Pale Moon/Profiles/") && path.contains("/cache2") {
            return "Pale Moon Cache"
        }

        // MARK: - Chromium Tabanlı Tarayıcılar (Dinamik Tespit)
        if path.contains("/Library/Application Support/") {
            // Chromium cache pattern kontrolü
            let chromiumCacheTypes = ["Cache", "Code Cache", "GPUCache",
                                      "ShaderCache", "GrShaderCache", "GraphiteDawnCache",
                                      "DawnWebGPUCache", "DawnGraphiteCache"]
            let lastComponent = url.lastPathComponent

            if chromiumCacheTypes.contains(lastComponent) {
                // Tarayıcı ismini path'ten çıkar
                let browserName = extractChromiumBrowserName(from: path)
                let cacheType: String
                switch lastComponent {
                case "GPUCache": cacheType = "GPU Cache"
                case "ShaderCache", "GrShaderCache": cacheType = "Shader Cache"
                case "GraphiteDawnCache", "DawnWebGPUCache", "DawnGraphiteCache": cacheType = "GPU Shader Cache"
                default: cacheType = lastComponent
                }
                // Default dışındaki profiller adda belirtilir ("Profile 1")
                let profile = url.deletingLastPathComponent().lastPathComponent
                let profileSuffix = profile.hasPrefix("Profile ") ? " (\(profile))" : ""
                return "\(browserName)\(profileSuffix) \(cacheType)"
            }
        }

        // MARK: - Sistem Log'ları
        if path.contains("/Library/Logs") { return "User Logs" }
        if path.contains("/var/log") { return "System Logs" }

        // MARK: - Genel ~/Library/Caches İçeriği
        let parent = url.deletingLastPathComponent().lastPathComponent
        if parent == "Caches" {
            // Bundle identifier'dan okunabilir isim oluştur
            let bundleID = url.lastPathComponent
            let readableName = formatBundleIdentifier(bundleID)
            return "\(readableName) Cache"
        }

        return url.lastPathComponent
    }

    var formattedSize: String {
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    // MARK: - Helper Methods

    /// Application Support path'inden Chromium tabanlı tarayıcı ismini çıkarır
    private func extractChromiumBrowserName(from path: String) -> String {
        // Path yapısı: ~/Library/Application Support/[BrowserFolder]/...
        let appSupportMarker = "/Library/Application Support/"

        guard let range = path.range(of: appSupportMarker) else {
            return "Browser"
        }

        let afterMarker = String(path[range.upperBound...])
        let components = afterMarker.split(separator: "/")

        guard let browserFolder = components.first else {
            return "Browser"
        }

        let folderName = String(browserFolder)

        // Bilinen tarayıcı klasör isimlerini okunabilir isimlere çevir
        let knownBrowsers: [String: String] = [
            "Google": "Google Chrome",
            "BraveSoftware": "Brave",
            "Microsoft Edge": "Microsoft Edge",
            "Vivaldi": "Vivaldi",
            "Opera Software": "Opera",
            "Arc": "Arc",
            "Chromium": "Chromium",
            "Coccoc": "Cốc Cốc",
            "Yandex": "Yandex",
            "SRWare Iron": "SRWare Iron",
            "Thorium": "Thorium",
            "Ungoogled Chromium": "Ungoogled Chromium",
            "Sidekick": "Sidekick",
            "Wavebox": "Wavebox",
            "Orion": "Orion",
            "Naver Whale": "Naver Whale",
            "360Chrome": "360 Browser",
            "CentBrowser": "Cent Browser",
            "Iridium": "Iridium"
        ]

        // Tam eşleşme kontrolü
        if let knownName = knownBrowsers[folderName] {
            return knownName
        }

        // Kısmi eşleşme kontrolü (örn: "Google" -> "Google Chrome")
        for (key, value) in knownBrowsers {
            if folderName.localizedCaseInsensitiveContains(key) {
                return value
            }
        }

        // Bilinmeyen tarayıcı - klasör ismini kullan
        return folderName
    }

    /// Bundle identifier'ı okunabilir bir isme dönüştürür
    /// Örn: "com.apple.finder" -> "Apple Finder"
    private func formatBundleIdentifier(_ bundleID: String) -> String {
        // "com.", "org.", "net." gibi prefixleri kaldır
        var cleaned = bundleID

        let prefixes = ["com.", "org.", "net.", "io.", "app.", "me."]
        for prefix in prefixes {
            if cleaned.lowercased().hasPrefix(prefix) {
                cleaned = String(cleaned.dropFirst(prefix.count))
                break
            }
        }

        // Noktalı bölümleri ayır ve her birini capitalize et
        let parts = cleaned.split(separator: ".")
        let formatted = parts.map { part -> String in
            let str = String(part)
            // camelCase veya PascalCase'i boşluklara ayır
            return str.replacingOccurrences(
                of: "([a-z])([A-Z])",
                with: "$1 $2",
                options: .regularExpression
            ).capitalized
        }

        return formatted.joined(separator: " ")
    }
}
