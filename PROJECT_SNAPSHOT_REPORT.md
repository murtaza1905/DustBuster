# 0) Snapshot Meta

* Tarih/saat: 2025-12-17T20:12:53+00:00
* Çalışma dizini: /Users/muratonurcu/Desktop/DustBuster 2.0
* İşletim sistemi: Darwin Murat-MacBook-Air.local 25.2.0 Darwin Kernel Version 25.2.0: Tue Nov 18 21:09:55 PST 2025; root:xnu-12377.61.12~1/RELEASE_ARM64_T8103 arm64
* Xcode: Xcode 26.2 | Build version 17C52
* Swift: Apple Swift version 6.2.3 (swiftlang-6.2.3.3.21 clang-1700.6.3.2) | Target: arm64-apple-macosx26.0
* Git HEAD: 555021fdbfd934bd76eeeae70aba73401b660947
* Git status: M CleanerApp.xcodeproj/project.pbxproj
 M CleanerApp/CleanerManager.swift
 M CleanerApp/CleanerReviewView.swift
 M CleanerApp/DashboardView.swift
 M CleanerApp/DashboardViewModel.swift
 M CleanerApp/MainDetailRouter.swift
 M CleanerApp/SafeDeleteService.swift
 M CleanerApp/SidebarItem.swift
 M CleanerApp/SidebarView.swift
 M CleanerApp/SystemMonitor.swift
 M CleanerApp/TrashHistoryStore.swift
?? CleanerApp/Info.plist
?? CleanerApp/UninstallerManager.swift
?? CleanerApp/UninstallerView.swift
?? CleanerApp/UninstallerViewModel.swift
?? dist/

# 1) Proje Ağacı (Özet)

Hariç tutulan klasörler: .git, build, dist, DMG_Contents, DerivedData, Pods, Carthage, .build, node_modules

```
├── .DS_Store (14340 bytes)
├── .gitignore (67 bytes)
├── build.log (80455 bytes)
├── build_macos14.log (70597 bytes)
├── build_review_ui.log (78025 bytes)
├── build_sheet_undo.log (78308 bytes)
├── build_trash_history.log (70618 bytes)
├── build_trashonly.log (70412 bytes)
├── build_uninstaller.log (78027 bytes)
├── build_uninstaller_v2.log (78025 bytes)
├── build_uninstaller_v3.log (78025 bytes)
├── CleanerApp/
│   ├── .DS_Store (10244 bytes)
│   ├── AppPermissionViewModel.swift (1257 bytes)
│   ├── Assets.xcassets/
│   │   ├── .DS_Store (10244 bytes)
│   │   ├── AccentColor.colorset/
│   │   │   └── Contents.json (695 bytes)
│   │   ├── AppIcon.appiconset/
│   │   │   ├── Contents.json (1294 bytes)
│   │   │   ├── icon_1024x1024.png (327719 bytes)
│   │   │   ├── icon_128x128.png (18143 bytes)
│   │   │   ├── icon_16x16.png (989 bytes)
│   │   │   ├── icon_256x256 1.png (52045 bytes)
│   │   │   ├── icon_256x256.png (52045 bytes)
│   │   │   ├── icon_32x32 1.png (2241 bytes)
│   │   │   ├── icon_32x32.png (2241 bytes)
│   │   │   ├── icon_512x512 1.png (134419 bytes)
│   │   │   ├── icon_512x512.png (134419 bytes)
│   │   │   └── icon_64x64.png (6101 bytes)
│   │   └── Contents.json (63 bytes)
│   ├── CleanerAppApp.swift (374 bytes)
│   ├── CleanerManager.swift (23788 bytes)
│   ├── CleanerReviewView.swift (11764 bytes)
│   ├── CleaningPlan.swift (3430 bytes)
│   ├── ContentView.swift (660 bytes)
│   ├── DashboardView.swift (13023 bytes)
│   ├── DashboardViewModel.swift (6369 bytes)
│   ├── FileItem.swift (5684 bytes)
│   ├── FullDiskAccessLockedView.swift (868 bytes)
│   ├── Info.plist (1304 bytes)
│   ├── LargeFileItem.swift (404 bytes)
│   ├── LargeFileManager.swift (3282 bytes)
│   ├── LargeFilesView.swift (5789 bytes)
│   ├── LargeFilesViewModel.swift (3246 bytes)
│   ├── LogManager.swift (8885 bytes)
│   ├── MainDetailRouter.swift (827 bytes)
│   ├── MaterialCard.swift (859 bytes)
│   ├── PermissionGate.swift (407 bytes)
│   ├── PermissionManager.swift (2509 bytes)
│   ├── ProcessItem.swift (281 bytes)
│   ├── ProcessListView.swift (4315 bytes)
│   ├── ProcessManager.swift (3014 bytes)
│   ├── SafeDeleteService.swift (22943 bytes)
│   ├── SettingsView.swift (6535 bytes)
│   ├── SidebarItem.swift (260 bytes)
│   ├── SidebarView.swift (1358 bytes)
│   ├── SystemMonitor.swift (9970 bytes)
│   ├── TrashHistoryStore.swift (2650 bytes)
│   ├── UninstallerManager.swift (29452 bytes)
│   ├── UninstallerView.swift (19791 bytes)
│   ├── UninstallerViewModel.swift (13468 bytes)
│   └── View+Glass.swift (1127 bytes)
├── CleanerApp.xcodeproj/
│   ├── project.pbxproj (11735 bytes)
│   ├── project.xcworkspace/
│   │   ├── contents.xcworkspacedata (135 bytes)
│   │   ├── xcshareddata/
│   │   │   └── swiftpm/
│   │   │       └── configuration/
│   │   └── xcuserdata/
│   │       └── muratonurcu.xcuserdatad/
│   │           └── UserInterfaceState.xcuserstate (66821 bytes)
│   └── xcuserdata/
│       └── muratonurcu.xcuserdatad/
│           └── xcschemes/
│               └── xcschememanagement.plist (345 bytes)
└── FULL_PROJECT_XRAY.md (10310 bytes)
```

# 2) Hızlı “Uninstall / AppCleaner benzeri” Odak Taraması

Anahtar kelime eşleşmeleri:

```
.swift:102:            home + "/Library/Caches/com.apple.Safari/WebKitCache"
CleanerApp/CleanerManager.swift:132:        DispatchQueue.global(qos: .userInitiated).async {
CleanerApp/CleanerManager.swift:133:            self.logManager.log("Cleanup scan başladı", category: .cleanup, level: .info)
CleanerApp/CleanerManager.swift:138:            self.detectDynamicBrowserCaches()
CleanerApp/CleanerManager.swift:141:            let chromiumItems = self.scanChromiumBrowserCaches()
CleanerApp/CleanerManager.swift:145:            let geckoItems = self.scanGeckoBrowserCaches()
CleanerApp/CleanerManager.swift:149:            let safariItems = self.scanSafariCaches()
CleanerApp/CleanerManager.swift:152:            // 5) Temel path'leri tara (~/Library/Caches, ~/Library/Logs, /private/var/log)
CleanerApp/CleanerManager.swift:163:                // ~/Library/Caches içeriğini tara (tarayıcı cache'leri hariç - zaten eklendi)
CleanerApp/CleanerManager.swift:164:                let foundItems = self.scanDirectory(at: url, excludeBrowserCaches: true)
CleanerApp/CleanerManager.swift:180:            self.logManager.log("Cleanup scan tamamlandı: \(items.count) kayıt, \(sizeText)", category: .cleanup, level: .info)
CleanerApp/CleanerManager.swift:206:        let rules = SafeDeleteService.Rules(
CleanerApp/CleanerManager.swift:214:        safeDeleteService.moveToTrash(plan: plan, rules: rules) { [weak self] result in
CleanerApp/CleanerManager.swift:218:            self.logManager.log("Cleanup bitti: \(movedText) Çöp Kutusu'na taşındı", category: .cleanup, level: .info)
CleanerApp/CleanerManager.swift:232:    func removeHistory(id: UUID) -> [TrashHistoryEntry] {
CleanerApp/CleanerManager.swift:233:        historyStore.remove(id)
CleanerApp/CleanerManager.swift:237:        DispatchQueue.global(qos: .userInitiated).async {
CleanerApp/CleanerManager.swift:255:                _ = self.historyStore.remove(entry.id)
CleanerApp/CleanerManager.swift:320:        DispatchQueue.global(qos: .userInitiated).async {
CleanerApp/CleanerManager.swift:346:                _ = self.historyStore.remove(trashedPaths: trashedPaths)
CleanerApp/CleanerManager.swift:382:    /// ~/Library/Application Support altındaki Chromium tabanlı tarayıcıları dinamik olarak tespit eder
CleanerApp/CleanerManager.swift:383:    private func detectDynamicBrowserCaches() {
CleanerApp/CleanerManager.swift:384:        dynamicBrowserCachePaths.removeAll()
CleanerApp/CleanerManager.swift:386:        let appSupportPath = home + "/Library/Application Support"
CleanerApp/CleanerManager.swift:396:            // Her Chromium cache pattern'ini kontrol et
CleanerApp/CleanerManager.swift:397:            for pattern in chromiumCachePatterns {
CleanerApp/CleanerManager.swift:398:                let cachePath = folderPath + "/" + pattern
CleanerApp/CleanerManager.swift:410:        logManager.log("Dinamik tarayıcı tespiti: \(dynamicBrowserCachePaths.count) Chromium cache bulundu", category: .cleanup, level: .info)
CleanerApp/CleanerManager.swift:414:    private func scanChromiumBrowserCaches() -> [FileItem] {
CleanerApp/CleanerManager.swift:431:    private func scanGeckoBrowserCaches() -> [FileItem] {
CleanerApp/CleanerManager.swift:465:    private func scanSafariCaches() -> [FileItem] {
CleanerApp/CleanerManager.swift:489:    private func scanDirectory(at url: URL, excludeBrowserCaches: Bool = false) -> [FileItem] {
CleanerApp/CleanerManager.swift:510:                if excludeBrowserCaches {
CleanerApp/CleanerManager.swift:521:                    // Chromium cache'leri zaten Application Support'ta, Caches'te değil
CleanerApp/CleanerManager.swift:581:        //    Not: Safari cache ~/Library/Caches altında, ~/Library/Safari değil
CleanerApp/CleanerManager.swift:583:            // Safari cache özel durumu - ~/Library/Safari yasak ama ~/Library/Caches/com.apple.Safari izinli
CleanerApp/CleanerManager.swift:596:        // 4) Application Support içindeyse sadece dinamik tespit edilen cache köklerinin altında olmalı
CleanerApp/CleanerManager.swift:597:        if path.contains("/Library/Application Support/") {
CleanerApp/CleanerManager.swift:606:        // 5) ~/Library/Caches altında history/cookies/login gibi şüpheli keyword içeriyorsa silme
CleanerApp/CleanerManager.swift:607:        let cachesRoot = home + "/Library/Caches"
CleanerApp/ProcessManager.swift:79:            self.processes.removeAll { $0.pid == process.pid }
CleanerApp/AppPermissionViewModel.swift:19:            NotificationCenter.default.removeObserver(observer)
CleanerApp/TrashHistoryStore.swift:71:    func remove(_ id: UUID) -> [TrashHistoryEntry] {
CleanerApp/TrashHistoryStore.swift:74:            current.removeAll { $0.id == id }
CleanerApp/TrashHistoryStore.swift:81:    func remove(trashedPaths: Set<String>) -> [TrashHistoryEntry] {
CleanerApp/TrashHistoryStore.swift:84:            current.removeAll { trashedPaths.contains($0.trashedURL.standardizedFileURL.path) }
CleanerApp/FileItem.swift:31:        if path.contains("/Caches/Firefox/Profiles/") && path.contains("/cache2") {
CleanerApp/FileItem.swift:34:        if path.contains("/Caches/LibreWolf/Profiles/") && path.contains("/cache2") {
CleanerApp/FileItem.swift:37:        if path.contains("/Caches/Waterfox/Profiles/") && path.contains("/cache2") {
CleanerApp/FileItem.swift:40:        if path.contains("/Caches/Pale Moon/Profiles/") && path.contains("/cache2") {
CleanerApp/FileItem.swift:45:        if path.contains("/Library/Application Support/") {
CleanerApp/FileItem.swift:46:            // Chromium cache pattern kontrolü
CleanerApp/FileItem.swift:62:        // MARK: - Genel ~/Library/Caches İçeriği
CleanerApp/FileItem.swift:64:        if parent == "Caches" {
CleanerApp/FileItem.swift:80:    /// Application Support path'inden Chromium tabanlı tarayıcı ismini çıkarır
CleanerApp/FileItem.swift:82:        // Path yapısı: ~/Library/Application Support/[BrowserFolder]/...
CleanerApp/FileItem.swift:83:        let appSupportMarker = "/Library/Application Support/"
CleanerApp/SystemMonitor.swift:67:        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
CleanerApp/UninstallerViewModel.swift:47:    @Published var uninstallHistory: [UninstallTransaction] = []  // Son 10 islem
CleanerApp/UninstallerViewModel.swift:82:        !uninstallHistory.isEmpty && !isUndoing && !isProcessing
CleanerApp/UninstallerViewModel.swift:87:        uninstallHistory.removeAll()
CleanerApp/UninstallerViewModel.swift:105:        // uninstallHistory'yi koruyoruz; diğer uygulamalar için geri alma mümkün kalsın.
CleanerApp/UninstallerViewModel.swift:182:            self.items.removeAll { movedSet.contains($0.url) }
CleanerApp/UninstallerViewModel.swift:203:                self.logManager.log("Uninstaller: \(adminCount) dosya admin yetkisiyle silindi", category: .cleanup, level: .info)
CleanerApp/UninstallerViewModel.swift:236:            self.logManager.log("Uninstaller \(appLabel): \(summary.moved) tasindi / \(summary.skipped) atlandi / \(summary.failed) hata", category: .cleanup, level: .info)
CleanerApp/UninstallerViewModel.swift:245:                self.uninstallHistory.insert(transaction, at: 0)
CleanerApp/UninstallerViewModel.swift:246:                if self.uninstallHistory.count > self.maxHistoryCount {
CleanerApp/UninstallerViewModel.swift:247:                    self.uninstallHistory = Array(self.uninstallHistory.prefix(self.maxHistoryCount))
CleanerApp/UninstallerViewModel.swift:263:        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
CleanerApp/UninstallerViewModel.swift:293:                    self.uninstallHistory.removeAll { $0.id == transaction.id }
CleanerApp/UninstallerViewModel.swift:295:                    self.logManager.log("Uninstaller undo: \(restoredCount)/\(transaction.items.count) öğe geri alındı (\(transaction.appName))", category: .cleanup, level: .info)
CleanerApp/UninstallerViewModel.swift:342:        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
CleanerApp/SafeDeleteService.swift:59:    func moveToTrash(plan: CleaningPlan, rules: Rules, completion: @escaping (CleaningResult) -> Void) {
CleanerApp/SafeDeleteService.swift:60:        DispatchQueue.global(qos: .userInitiated).async {
CleanerApp/SafeDeleteService.swift:70:                guard rules.isPathAllowed(path) else {
CleanerApp/SafeDeleteService.swift:77:                guard self.isForbidden(path: path, forbiddenRoots: rules.forbiddenPaths) == false else {
CleanerApp/SafeDeleteService.swift:146:        DispatchQueue.global(qos: .userInitiated).async {
CleanerApp/SafeDeleteService.swift:189:                        self.logManager.log("Çöp Kutusu: \(url.lastPathComponent) -> \(trashed.path ?? "Trash")", category: .cleanup, level: .info)
CleanerApp/SafeDeleteService.swift:192:                        self.logManager.log("Çöp Kutusu: \(url.lastPathComponent)", category: .cleanup, level: .info)
CleanerApp/SafeDeleteService.swift:296:        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
CleanerApp/SafeDeleteService.swift:380:        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
CleanerApp/SafeDeleteService.swift:428:                    self.logManager.log("Cop Kutusu: \(url.lastPathComponent)", category: .cleanup, level: .info)
CleanerApp/SafeDeleteService.swift:468:                        self.logManager.log("Cop Kutusu (admin): \(url.lastPathComponent)", category: .cleanup, level: .info)
CleanerApp/DashboardViewModel.swift:117:                updatedPlan.candidates.removeAll { movedIDs.contains($0.id) }
```

# 3) Tam Dosya İçerikleri (Full Contents)

## FILE: CleanerApp/AppPermissionViewModel.swift

```swift
import Foundation
import AppKit
import Combine

final class AppPermissionViewModel: ObservableObject {
    @Published var hasFullDiskAccess: Bool = false

    private let permissionManager = PermissionManager.shared
    private var activationObserver: NSObjectProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bind()
        setup()
    }
    
    deinit {
        if let observer = activationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func bind() {
        permissionManager.$hasFullDiskAccess
            .receive(on: DispatchQueue.main)
            .assign(to: \.hasFullDiskAccess, on: self)
            .store(in: &cancellables)
    }
    
    private func setup() {
        refreshFullDiskAccessStatus()
        
        activationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshFullDiskAccessStatus()
            }
        }
    }
    
    func refreshFullDiskAccessStatus() {
        permissionManager.checkFullDiskAccess()
    }
}

```

---

## FILE: CleanerApp/Assets.xcassets/AccentColor.colorset/Contents.json

```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "1.000",
          "green" : "0.620",
          "red" : "0.290"
        }
      },
      "idiom" : "universal"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "1.000",
          "green" : "0.690",
          "red" : "0.353"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}

```

---

## FILE: CleanerApp/Assets.xcassets/AppIcon.appiconset/Contents.json

```json
{
  "images" : [
    {
      "filename" : "icon_16x16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32 1.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_64x64.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128x128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256 1.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512 1.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_1024x1024.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}

```

---

## FILE: CleanerApp/Assets.xcassets/Contents.json

```json
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}

```

---

## FILE: CleanerApp/CleanerAppApp.swift

```swift
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

```

---

## FILE: CleanerApp/CleanerManager.swift

```swift
// Sources/Managers/CleanerManager.swift

import Foundation
import Combine

/// Manages safe file deletion and system cleaning.
class CleanerManager: ObservableObject {

    // ObservableObject requirement
    let objectWillChange = ObservableObjectPublisher()
    private let permissionManager = PermissionManager.shared
    private let logManager = LogManager.shared
    private let safeDeleteService = SafeDeleteService()
    private let historyStore = TrashHistoryStore.shared

    struct TrashMoveRecord {
        let originalURL: URL
        let trashedURL: URL
        let size: Int64?
        let displayName: String
    }

    struct TrashTransaction {
        let id: UUID
        let date: Date
        let items: [TrashMoveRecord]
        let totalBytes: Int64
    }

    // MARK: - Paths & Safety Rules

    /// Temel whitelist path'leri (Caches, Logs, vs.)
    private let baseAllowedPaths: [String]

    /// Dinamik olarak tespit edilen tarayıcı cache path'leri
    private var dynamicBrowserCachePaths: [String] = []

    /// Tüm izin verilen path'ler (base + dinamik)
    private var allowedBasePaths: [String] {
        baseAllowedPaths + dynamicBrowserCachePaths
    }

    /// Asla dokunulmaması gereken path kökleri (sistem + kullanıcı verisi).
    private let forbiddenPaths: [String]

    /// Cache path'lerinde geçerse riskli sayılacak anahtar kelimeler.
    /// (İhtiyaten history / cookies / login vb. içeren cache path'lerini de bloklar)
    private let sensitiveKeywords: [String] = [
        "history",
        "bookmark",
        "bookmarks",
        "cookies",
        "keychain",
        "account",
        "accounts",
        "login",
        "logindata",
        "session",
        "sessions",
        "autofill"
    ]

    /// Chromium tabanlı tarayıcılarda aranan cache klasör yapıları
    private let chromiumCachePatterns: [String] = [
        "Default/Cache",
        "Default/Code Cache",
        "Default/GPUCache",
        "User Data/Default/Cache",
        "User Data/Default/Code Cache",
        "User Data/Default/GPUCache"
    ]

    /// Gecko tabanlı tarayıcılar (Firefox ailesi) - ~/Library/Caches altında
    private let geckoBasePaths: [String]

    /// Safari cache path'leri
    private let safariCachePaths: [String]

    // MARK: - Init

    init() {
        let home = NSHomeDirectory()

        // Genel, tüm uygulamalar için geçerli güvenli temizlik alanları
        self.baseAllowedPaths = [
            home + "/Library/Caches",   // Uygulama cache'leri
            home + "/Library/Logs",     // Kullanıcı log'ları
            "/private/var/log"          // Sistem log'ları (Full Disk Access ile)
        ]

        // Gecko tabanlı tarayıcıların cache kökleri
        self.geckoBasePaths = [
            home + "/Library/Caches/Firefox/Profiles",
            home + "/Library/Caches/LibreWolf/Profiles",
            home + "/Library/Caches/Waterfox/Profiles",
            home + "/Library/Caches/Pale Moon/Profiles"
        ]

        // Safari cache path'leri
        self.safariCachePaths = [
            home + "/Library/Caches/com.apple.Safari",
            home + "/Library/Caches/com.apple.Safari/WebKitCache"
        ]

        // Asla dokunulmaması gereken path kökleri
        self.forbiddenPaths = [
            "/System",
            "/Library",
            "/bin",
            "/sbin",
            "/usr",
            "/Applications"
        ]
    }
    
    // MARK: - Public API

    /// Whitelist'e göre tüm hedef alanları tarar ve silinebilecek item listesini döner.
    func scan(completion: @escaping (CleaningPlan) -> Void) {
        permissionManager.checkFullDiskAccess()
        if permissionManager.hasFullDiskAccess == false {
            #if DEBUG
            print("Full Disk Access yok, sistem temizliği taraması iptal edildi")
            #endif
            logManager.log("Cleanup scan blocked: Full Disk Access yok", category: .audit, level: .warning)
            DispatchQueue.main.async {
                completion(CleaningPlan(candidates: []))
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.logManager.log("Cleanup scan başladı", category: .cleanup, level: .info)
            var items: [FileItem] = []
            let fileManager = FileManager.default

            // 1) Dinamik tarayıcı cache'lerini tespit et
            self.detectDynamicBrowserCaches()

            // 2) Chromium tabanlı tarayıcı cache'lerini tara
            let chromiumItems = self.scanChromiumBrowserCaches()
            items.append(contentsOf: chromiumItems)

            // 3) Gecko tabanlı tarayıcı cache'lerini tara (Firefox ailesi)
            let geckoItems = self.scanGeckoBrowserCaches()
            items.append(contentsOf: geckoItems)

            // 4) Safari cache'lerini tara
            let safariItems = self.scanSafariCaches()
            items.append(contentsOf: safariItems)

            // 5) Temel path'leri tara (~/Library/Caches, ~/Library/Logs, /private/var/log)
            for basePath in self.baseAllowedPaths {
                if basePath.hasPrefix("/private/var/log"),
                   self.permissionManager.hasFullDiskAccess == false {
                    print("Full Disk Access yok, /private/var/log taranmadı")
                    continue
                }

                guard fileManager.fileExists(atPath: basePath) else { continue }
                let url = URL(fileURLWithPath: basePath)

                // ~/Library/Caches içeriğini tara (tarayıcı cache'leri hariç - zaten eklendi)
                let foundItems = self.scanDirectory(at: url, excludeBrowserCaches: true)
                items.append(contentsOf: foundItems)
            }

            // Duplicate'leri kaldır (path bazlı)
            var seenPaths = Set<String>()
            items = items.filter { item in
                if seenPaths.contains(item.path) {
                    return false
                }
                seenPaths.insert(item.path)
                return true
            }

            let totalSize = items.reduce(Int64(0)) { $0 + $1.size }
            let sizeText = ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
            self.logManager.log("Cleanup scan tamamlandı: \(items.count) kayıt, \(sizeText)", category: .cleanup, level: .info)

            let plan = self.buildPlan(from: items)

            DispatchQueue.main.async {
                completion(plan)
            }
        }
    }
    
    /// Verilen temizlik planını güvenlik kuralları ile uygular.
    func apply(plan: CleaningPlan, completion: @escaping (CleaningResult) -> Void) {
        permissionManager.checkFullDiskAccess()
        if permissionManager.hasFullDiskAccess == false {
            #if DEBUG
            print("Full Disk Access yok, sistem temizliği iptal edildi")
            #endif
            logManager.log("Cleanup iptal edildi: Full Disk Access yok", category: .audit, level: .warning)
            let skipped = plan.selectedCandidates
            let emptyResult = CleaningResult(moved: [], skipped: skipped, failed: [], totalMovedBytes: 0, notes: [])
            DispatchQueue.main.async {
                completion(emptyResult)
            }
            return
        }

        let rules = SafeDeleteService.Rules(
            forbiddenPaths: forbiddenPaths,
            isPathAllowed: { [weak self] path in
                guard let self = self else { return false }
                return self.isSafeToDelete(path: path)
            }
        )

        safeDeleteService.moveToTrash(plan: plan, rules: rules) { [weak self] result in
            guard let self = self else { return }
            self.logManager.log("Temizlik uygulandı: \(result.summaryLine)", category: .audit, level: .info)
            let movedText = ByteCountFormatter.string(fromByteCount: result.totalMovedBytes, countStyle: .file)
            self.logManager.log("Cleanup bitti: \(movedText) Çöp Kutusu'na taşındı", category: .cleanup, level: .info)
            let historyEntries = self.buildHistoryEntries(from: result)
            if historyEntries.isEmpty == false {
                _ = self.historyStore.append(historyEntries)
                self.logManager.log("History eklendi: \(historyEntries.count) kayıt", category: .audit, level: .info)
            }
            completion(result)
        }
    }

    func loadHistory() -> [TrashHistoryEntry] {
        historyStore.load()
    }

    func removeHistory(id: UUID) -> [TrashHistoryEntry] {
        historyStore.remove(id)
    }

    func restore(entry: TrashHistoryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fm = FileManager.default

            if fm.fileExists(atPath: entry.originalURL.path) {
                let error = NSError(domain: "DustBuster.Restore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Hedef konumda zaten bir dosya var."])
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            if self.isSymlink(entry.trashedURL) || self.isSymlink(entry.originalURL) {
                let error = NSError(domain: "DustBuster.Restore", code: 2, userInfo: [NSLocalizedDescriptionKey: "Symlink restore edilmiyor."])
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            do {
                try fm.createDirectory(at: entry.originalURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                try fm.moveItem(at: entry.trashedURL, to: entry.originalURL)
                _ = self.historyStore.remove(entry.id)
                DispatchQueue.main.async { completion(.success(())) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    // MARK: - Plan building

    private func buildPlan(from items: [FileItem]) -> CleaningPlan {
        let candidates: [CleaningCandidate] = items.compactMap { item in
            makeCandidate(from: item)
        }
        return CleaningPlan(candidates: candidates)
    }

    private func makeCandidate(from item: FileItem) -> CleaningCandidate? {
        guard let identity = FileIdentitySnapshot(url: item.url) else {
            logManager.log("Plan skip: kimlik alınamadı", category: .audit, level: .warning)
            return nil
        }

        if identity.isSymbolicLink {
            logManager.log("Plan skip: symlink bulundu", category: .audit, level: .warning)
            return nil
        }

        return CleaningCandidate(
            url: item.url,
            size: item.size,
            isDirectory: item.isDirectory,
            isSelected: item.isSelected,
            displayName: item.displayName,
            identity: identity
        )
    }

    private func buildHistoryEntries(from result: CleaningResult) -> [TrashHistoryEntry] {
        result.moved.compactMap { movedItem in
            guard let trashedURL = movedItem.trashedURL else { return nil }
            return TrashHistoryEntry(
                originalURL: movedItem.candidate.url,
                trashedURL: trashedURL,
                size: movedItem.candidate.size,
                displayName: movedItem.candidate.displayName
            )
        }
    }

    func makeTransaction(from result: CleaningResult) -> TrashTransaction? {
        let records: [TrashMoveRecord] = result.moved.compactMap { movedItem in
            guard let trashedURL = movedItem.trashedURL else { return nil }
            return TrashMoveRecord(
                originalURL: movedItem.candidate.url,
                trashedURL: trashedURL,
                size: movedItem.candidate.size,
                displayName: movedItem.candidate.displayName
            )
        }
        guard !records.isEmpty else { return nil }
        return TrashTransaction(id: UUID(), date: Date(), items: records, totalBytes: result.totalMovedBytes)
    }

    func undo(transaction: TrashTransaction, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fm = FileManager.default
            var errors: [Error] = []

            for record in transaction.items {
                let original = record.originalURL.standardizedFileURL
                let trashed = record.trashedURL.standardizedFileURL

                if self.isSymlink(original) || self.isSymlink(trashed) {
                    continue
                }

                guard fm.fileExists(atPath: trashed.path) else { continue }

                let target = self.safeRestoreTarget(for: original, fileManager: fm)

                do {
                    try fm.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
                    try fm.moveItem(at: trashed, to: target)
                } catch {
                    errors.append(error)
                }
            }

            if errors.isEmpty {
                let trashedPaths = Set(transaction.items.map { $0.trashedURL.standardizedFileURL.path })
                _ = self.historyStore.remove(trashedPaths: trashedPaths)
                self.logManager.log("Undo başarı: \(transaction.items.count) öğe", category: .audit, level: .info)
                DispatchQueue.main.async { completion(.success(())) }
            } else {
                let first = errors.first!
                self.logManager.log("Undo hata: \(first.localizedDescription)", category: .error, level: .error)
                DispatchQueue.main.async { completion(.failure(first)) }
            }
        }
    }

    private func safeRestoreTarget(for original: URL, fileManager: FileManager) -> URL {
        if !fileManager.fileExists(atPath: original.path) {
            return original
        }
        let base = original.deletingPathExtension()
        let ext = original.pathExtension.isEmpty ? nil : original.pathExtension
        var counter = 1
        while true {
            let candidateName = "\(base.lastPathComponent) (Restored \(counter))"
            var candidate = base.deletingLastPathComponent().appendingPathComponent(candidateName)
            if let ext { candidate.appendPathExtension(ext) }
            if !fileManager.fileExists(atPath: candidate.path) {
                return candidate
            }
            counter += 1
        }
    }

    private func isSymlink(_ url: URL) -> Bool {
        let values = try? url.resourceValues(forKeys: [.isSymbolicLinkKey])
        return values?.isSymbolicLink ?? false
    }
    
    // MARK: - Dynamic Browser Detection

    /// ~/Library/Application Support altındaki Chromium tabanlı tarayıcıları dinamik olarak tespit eder
    private func detectDynamicBrowserCaches() {
        dynamicBrowserCachePaths.removeAll()
        let home = NSHomeDirectory()
        let appSupportPath = home + "/Library/Application Support"
        let fileManager = FileManager.default

        guard let contents = try? fileManager.contentsOfDirectory(atPath: appSupportPath) else {
            return
        }

        for folderName in contents {
            let folderPath = appSupportPath + "/" + folderName

            // Her Chromium cache pattern'ini kontrol et
            for pattern in chromiumCachePatterns {
                let cachePath = folderPath + "/" + pattern

                if fileManager.fileExists(atPath: cachePath) {
                    // Bu bir Chromium tabanlı tarayıcı cache'i
                    dynamicBrowserCachePaths.append(cachePath)
                    #if DEBUG
                    print("Chromium cache tespit edildi: \(cachePath)")
                    #endif
                }
            }
        }

        logManager.log("Dinamik tarayıcı tespiti: \(dynamicBrowserCachePaths.count) Chromium cache bulundu", category: .cleanup, level: .info)
    }

    /// Chromium tabanlı tarayıcı cache'lerini tarar
    private func scanChromiumBrowserCaches() -> [FileItem] {
        var results: [FileItem] = []

        for cachePath in dynamicBrowserCachePaths {
            let url = URL(fileURLWithPath: cachePath)
            guard isSafeToDelete(path: cachePath) else { continue }

            let size = getPathSize(url: url)
            if size > 0 {
                results.append(FileItem(url: url, size: size, isDirectory: true))
            }
        }

        return results
    }

    /// Gecko tabanlı tarayıcı cache'lerini tarar (Firefox, LibreWolf, Waterfox, Pale Moon)
    private func scanGeckoBrowserCaches() -> [FileItem] {
        var results: [FileItem] = []
        let fileManager = FileManager.default

        for geckoBasePath in geckoBasePaths {
            guard fileManager.fileExists(atPath: geckoBasePath) else { continue }

            // Profil klasörlerini tara
            guard let profiles = try? fileManager.contentsOfDirectory(atPath: geckoBasePath) else {
                continue
            }

            for profileName in profiles {
                let profilePath = geckoBasePath + "/" + profileName
                let cache2Path = profilePath + "/cache2"

                guard fileManager.fileExists(atPath: cache2Path) else { continue }
                guard isSafeToDelete(path: cache2Path) else { continue }

                let url = URL(fileURLWithPath: cache2Path)
                let size = getPathSize(url: url)
                if size > 0 {
                    results.append(FileItem(url: url, size: size, isDirectory: true))
                    #if DEBUG
                    print("Gecko cache tespit edildi: \(cache2Path)")
                    #endif
                }
            }
        }

        return results
    }

    /// Safari cache'lerini tarar
    private func scanSafariCaches() -> [FileItem] {
        var results: [FileItem] = []
        let fileManager = FileManager.default

        for safariPath in safariCachePaths {
            guard fileManager.fileExists(atPath: safariPath) else { continue }
            guard isSafeToDelete(path: safariPath) else { continue }

            let url = URL(fileURLWithPath: safariPath)
            let size = getPathSize(url: url)
            if size > 0 {
                results.append(FileItem(url: url, size: size, isDirectory: true))
                #if DEBUG
                print("Safari cache tespit edildi: \(safariPath)")
                #endif
            }
        }

        return results
    }

    // MARK: - Internal Scanning Logic

    /// Verilen dizinin sadece top-level içeriğini (alt klasörlerin kendisini) item olarak döner.
    private func scanDirectory(at url: URL, excludeBrowserCaches: Bool = false) -> [FileItem] {
        var results: [FileItem] = []
        let fileManager = FileManager.default

        let options: FileManager.DirectoryEnumerationOptions = [
            .skipsHiddenFiles,
            .skipsPackageDescendants,
            .skipsSubdirectoryDescendants
        ]

        do {
            let contents = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
                options: options
            )

            for fileURL in contents {
                let path = fileURL.path

                // Tarayıcı cache'lerini hariç tut (zaten ayrıca eklendi)
                if excludeBrowserCaches {
                    // Safari cache'leri
                    if safariCachePaths.contains(where: { path.hasPrefix($0) || $0.hasPrefix(path) }) {
                        continue
                    }

                    // Gecko cache'leri
                    if geckoBasePaths.contains(where: { path.hasPrefix($0) || $0.hasPrefix(path) }) {
                        continue
                    }

                    // Chromium cache'leri zaten Application Support'ta, Caches'te değil
                }

                guard isSafeToDelete(path: path) else { continue }

                let size = getPathSize(url: fileURL)
                if size <= 0 { continue }

                let isDir = (try? fileURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                results.append(FileItem(url: fileURL, size: size, isDirectory: isDir))
            }
        } catch {
            print("Scan error for \(url.path): \(error)")
        }

        return results
    }

    /// Dosya veya klasörün recursive boyutunu hesaplar.
    private func getPathSize(url: URL) -> Int64 {
        let fileManager = FileManager.default
        var size: Int64 = 0

        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                   let fileSize = resourceValues.fileSize {
                    size += Int64(fileSize)
                }
            }
        }
        return size
    }
    
    // MARK: - Core Safety Check

    /// Tüm güvenlik kurallarını uygular.
    /// Sadece gerçekten silinmesi güvenli path'ler için true döner.
    private func isSafeToDelete(path: String) -> Bool {
        let home = NSHomeDirectory()

        // 1) Mutlaka whitelist içindeki köklerden biriyle başlamalı
        //    (base paths + dinamik tespit edilen tarayıcı cache'leri + gecko + safari)
        let isUnderAllowedBase = allowedBasePaths.contains { allowed in
            path.hasPrefix(allowed)
        }

        // Gecko cache path'leri için özel kontrol
        let isGeckoCache = geckoBasePaths.contains { geckoBase in
            path.hasPrefix(geckoBase)
        }

        // Safari cache path'leri için özel kontrol
        let isSafariCache = safariCachePaths.contains { safariPath in
            path.hasPrefix(safariPath)
        }

        guard isUnderAllowedBase || isGeckoCache || isSafariCache else { return false }

        // 2) Asla dokunulmaması gereken köklerle başlamamalı
        //    Not: Safari cache ~/Library/Caches altında, ~/Library/Safari değil
        if forbiddenPaths.contains(where: { forbidden in path.hasPrefix(forbidden) }) {
            // Safari cache özel durumu - ~/Library/Safari yasak ama ~/Library/Caches/com.apple.Safari izinli
            if isSafariCache {
                // Safari cache'i için bu kontrolü atla
            } else {
                return false
            }
        }

        // 3) Kullanıcı home veya root asla silinmesin
        if path == home || path == "/" {
            return false
        }

        // 4) Application Support içindeyse sadece dinamik tespit edilen cache köklerinin altında olmalı
        if path.contains("/Library/Application Support/") {
            let isInDynamicCache = dynamicBrowserCachePaths.contains { allowedCache in
                path.hasPrefix(allowedCache)
            }
            if !isInDynamicCache {
                return false
            }
        }

        // 5) ~/Library/Caches altında history/cookies/login gibi şüpheli keyword içeriyorsa silme
        let cachesRoot = home + "/Library/Caches"
        if path.hasPrefix(cachesRoot) {
            if sensitiveKeywords.contains(where: { keyword in
                path.localizedCaseInsensitiveContains(keyword)
            }) {
                return false
            }
        }

        // 6) macOS "deletable" olarak işaretlemiyorsa silme
        if !FileManager.default.isDeletableFile(atPath: path) {
            return false
        }

        return true
    }
}

```

---

## FILE: CleanerApp/CleanerReviewView.swift

```swift
import SwiftUI

private enum CleanerSortKey: String, CaseIterable, Identifiable {
    case name
    case size
    case path
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .name: return "İsim"
        case .size: return "Boyut"
        case .path: return "Konum"
        }
    }
}

private enum CleanerSortOrder: String, CaseIterable, Identifiable {
    case ascending
    case descending
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .ascending:  return "Küçük → Büyük"
        case .descending: return "Büyük → Küçük"
        }
    }
}

private enum CleanerReviewTab: String, CaseIterable, Identifiable {
    case items = "Öğeler"
    case history = "Geçmiş"

    var id: String { rawValue }
}

struct CleanerReviewView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var sortKey: CleanerSortKey = .size
    @State private var sortOrder: CleanerSortOrder = .descending
    @State private var showConfirmation: Bool = false
    @State private var selectedTab: CleanerReviewTab = .items
    
    private var plan: CleaningPlan? {
        viewModel.cleaningPlan
    }
    
    // Seçenekler listesi (view içinde sıralanmış)
    private var sortedItems: [CleaningCandidate] {
        guard let plan else { return [] }
        let base = plan.candidates
        
        let sorted: [CleaningCandidate]
        switch sortKey {
        case .name:
            sorted = base.sorted {
                $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
            }
        case .size:
            sorted = base.sorted { $0.size < $1.size }
        case .path:
            sorted = base.sorted {
                $0.path.localizedCaseInsensitiveCompare($1.path) == .orderedAscending
            }
        }
        
        return (sortOrder == .ascending) ? sorted : sorted.reversed()
    }
    
    private var hasSelectedItems: Bool {
        plan?.hasSelection ?? false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            summaryBadges
            tabSelector
            Divider()
            mainContent
            Divider()
            footer
        }
        .frame(
            minWidth: 700,
            idealWidth: 850,
            maxWidth: 1000,
            minHeight: 500,
            idealHeight: 650,
            maxHeight: 800
        )
        .confirmationDialog(
            "Seçili öğeler Çöp Kutusu'na taşınacak.",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button("Çöp Kutusuna Taşı", role: .destructive) {
                viewModel.cleanSelectedItems()
            }
            .disabled(!hasSelectedItems)
            Button("Vazgeç", role: .cancel) { }
        }
        .alert(
            "Geri Al Hatası",
            isPresented: Binding(
                get: { viewModel.restoreErrorMessage != nil },
                set: { _ in viewModel.restoreErrorMessage = nil }
            )
        ) {
            Button("Tamam", role: .cancel) { viewModel.restoreErrorMessage = nil }
        } message: {
            Text(viewModel.restoreErrorMessage ?? "Bilinmeyen hata")
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Temizlik Planı İncelemesi")
                .font(.title3)
                .bold()
            Text("Tarama sonucu bulunan dosyaları gözden geçir ve Çöp Kutusu'na taşı.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }
    
    // MARK: - Summary badges

    private var summaryBadges: some View {
        VStack(spacing: 8) {
            // Üst satır: Boyut badge'leri ve sonuç
            HStack {
                badge(text: "Toplam \(viewModel.totalScanSize)", color: .blue)
                badge(text: "Seçili \(viewModel.selectedScanSize)", color: .purple)
                Spacer()
                if let result = viewModel.cleaningResult {
                    Text(result.summaryLine)
                        .font(.subheadline)
                        .foregroundColor(result.hasFailures ? .orange : .secondary)
                }
            }
            
            // Alt satır: Seçim ve sıralama kontrolleri
            HStack(spacing: 12) {
                Button {
                    viewModel.selectAllScannedItems()
                } label: {
                    Label("Tümünü Seç", systemImage: "checkmark.square")
                }
                .buttonStyle(.bordered)
                .disabled(plan == nil || plan?.candidates.isEmpty == true)
                
                Button {
                    viewModel.clearScannedSelection()
                } label: {
                    Label("Seçimi Temizle", systemImage: "xmark.square")
                }
                .buttonStyle(.bordered)
                .disabled(!hasSelectedItems)
                
                Spacer()
                
                Text("Sırala:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("", selection: $sortKey) {
                    ForEach(CleanerSortKey.allCases) { key in
                        Text(key.title).tag(key)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 100)
                
                Button {
                    toggleSortOrder()
                } label: {
                    Image(systemName: sortOrder == .ascending ? "arrow.up" : "arrow.down")
                }
                .buttonStyle(.bordered)
                .help(sortOrder == .ascending ? "Küçükten büyüğe" : "Büyükten küçüğe")
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private func badge(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.12))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
    
    // MARK: - Tabs

    private var tabSelector: some View {
        Picker("", selection: $selectedTab) {
            ForEach(CleanerReviewTab.allCases) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // MARK: - Content

    private var mainContent: some View {
        Group {
            if selectedTab == .items {
                list
            } else {
                historySection
            }
        }
    }
    
    // MARK: - Liste
    
    private var list: some View {
        List {
            if sortedItems.isEmpty {
                Text("Temizlenecek dosya bulunamadı.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(sortedItems) { item in
                    HStack {
                        Toggle("", isOn: Binding(
                            get: { item.isSelected },
                            set: { _ in viewModel.toggleSelection(for: item.id) }
                        ))
                        .toggleStyle(CheckboxToggleStyle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.displayName)
                                .font(.body)
                            Text(item.path)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        Spacer()
                        Text(item.formattedSize)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Çöp Kutusu Geçmişi (son 50)")
                    .font(.headline)
                Spacer()
                if viewModel.isRestoring {
                    ProgressView().scaleEffect(0.7)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            if viewModel.trashHistory.isEmpty {
                Text("Henüz geçmiş yok.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                List {
                    ForEach(viewModel.trashHistory) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.displayName)
                                    .font(.subheadline)
                                Text("\(entry.formattedDate) • \(entry.formattedSize)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Geri Al") {
                                viewModel.restore(entry: entry)
                            }
                            .buttonStyle(.bordered)
                            .disabled(viewModel.isRestoring)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Footer
    
    private var footer: some View {
        HStack {
            Button("Kapat") {
                presentationMode.wrappedValue.dismiss()
            }
            .keyboardShortcut(.cancelAction)
            
            Spacer()

            Button {
                viewModel.undoLastTransaction()
            } label: {
                HStack {
                    if viewModel.isUndoing {
                        ProgressView().scaleEffect(0.7)
                    }
                    Image(systemName: "arrow.uturn.backward")
                    Text("Geri Al")
                }
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.lastTrashTransaction == nil || viewModel.isUndoing)
            
            Button(action: {
                showConfirmation = true
            }) {
                HStack {
                    if viewModel.isCleaning {
                        ProgressView().scaleEffect(0.7)
                    } else {
                        Image(systemName: "trash")
                    }
                    Text("Çöp Kutusuna Taşı")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!hasSelectedItems || viewModel.isCleaning)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Helpers
    
    private func toggleSortOrder() {
        sortOrder = (sortOrder == .ascending) ? .descending : .ascending
    }
}

```

---

## FILE: CleanerApp/CleaningPlan.swift

```swift
import Foundation

struct FileIdentitySnapshot: Hashable {
    let resourceIdentifier: Data?
    let modificationDate: Date?
    let isSymbolicLink: Bool

    init?(url: URL) {
        guard let values = try? url.resourceValues(forKeys: [
            .contentModificationDateKey,
            .fileResourceIdentifierKey,
            .isSymbolicLinkKey
        ]) else {
            return nil
        }

        if let data = values.fileResourceIdentifier as? Data {
            self.resourceIdentifier = data
        } else if let identifier = values.fileResourceIdentifier {
            self.resourceIdentifier = try? NSKeyedArchiver.archivedData(
                withRootObject: identifier,
                requiringSecureCoding: false
            )
        } else {
            self.resourceIdentifier = nil
        }

        self.modificationDate = values.contentModificationDate
        self.isSymbolicLink = values.isSymbolicLink ?? false
    }

    func matches(_ other: FileIdentitySnapshot) -> Bool {
        if let lhs = resourceIdentifier, let rhs = other.resourceIdentifier {
            if lhs != rhs { return false }
        } else if resourceIdentifier != nil || other.resourceIdentifier != nil {
            return false
        }

        if let lhsDate = modificationDate, let rhsDate = other.modificationDate {
            if lhsDate != rhsDate { return false }
        } else if modificationDate != nil || other.modificationDate != nil {
            return false
        }

        return true
    }
}

struct CleaningCandidate: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let size: Int64
    let isDirectory: Bool
    var isSelected: Bool
    let displayName: String
    let identity: FileIdentitySnapshot

    var path: String {
        url.path
    }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

struct CleaningPlan: Hashable {
    var candidates: [CleaningCandidate]

    var totalSize: Int64 {
        candidates.reduce(0) { $0 + $1.size }
    }

    var selectedSize: Int64 {
        selectedCandidates.reduce(0) { $0 + $1.size }
    }

    var selectedCandidates: [CleaningCandidate] {
        candidates.filter { $0.isSelected }
    }

    var hasSelection: Bool {
        !selectedCandidates.isEmpty
    }

    mutating func toggleSelection(for candidateID: UUID) {
        guard let index = candidates.firstIndex(where: { $0.id == candidateID }) else { return }
        candidates[index].isSelected.toggle()
    }

    mutating func selectAll() {
        for index in candidates.indices {
            candidates[index].isSelected = true
        }
    }

    mutating func clearSelection() {
        for index in candidates.indices {
            candidates[index].isSelected = false
        }
    }
}

struct CleaningResult {
    struct MovedItem: Hashable {
        let candidate: CleaningCandidate
        let trashedURL: URL?
    }

    let moved: [MovedItem]
    let skipped: [CleaningCandidate]
    let failed: [CleaningCandidate]
    let totalMovedBytes: Int64
    let notes: [String]

    var hasFailures: Bool {
        !failed.isEmpty
    }

    var summaryLine: String {
        let movedText = ByteCountFormatter.string(fromByteCount: totalMovedBytes, countStyle: .file)
        return "Taşındı: \(moved.count), Atlandı: \(skipped.count), Hata: \(failed.count), Toplam: \(movedText)"
    }
}

```

---

## FILE: CleanerApp/ContentView.swift

```swift
// Sources/ContentView.swift
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

```

---

## FILE: CleanerApp/DashboardView.swift

```swift
// Sources/Views/DashboardView.swift
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var permissionVM: AppPermissionViewModel
    @StateObject var viewModel = DashboardViewModel()
    @State private var showFullDiskAccessAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Text("Sistem Durumu")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                    if !viewModel.permissionManager.hasFullDiskAccess {
                        Button(action: viewModel.openSettings) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Disk Erişimi Gerekli")
                            }
                        }
                        .adaptiveGlassButtonStyle(prominent: false)
                        .tint(.orange)
                    }
                }
                
                // System Monitor Cards
                HStack(spacing: 16) {
                    UsageCard(
                        title: "RAM Kullanımı",
                        percentage: viewModel.ramUsage,
                        primaryColor: .green,
                        usedText: "Kullanılan: \(viewModel.systemMonitor.memoryUsedString)",
                        freeText: "Boş: \(viewModel.systemMonitor.memoryFreeString)",
                        totalText: "Toplam: \(viewModel.systemMonitor.memoryTotalString)"
                    )
                    
                    UsageCard(
                        title: "Disk Kullanımı",
                        percentage: viewModel.diskUsage,
                        primaryColor: .yellow,
                        usedText: "Kullanılan: \(viewModel.systemMonitor.diskUsedString)",
                        freeText: "Boş: \(viewModel.systemMonitor.diskFreeString)",
                        totalText: "Toplam: \(viewModel.systemMonitor.diskTotalString)"
                    )
                    
                    UsageCard(
                        title: "CPU Kullanımı",
                        percentage: viewModel.cpuUsage,
                        primaryColor: .orange,
                        usedText: viewModel.systemMonitor.cpuBusyString,
                        freeText: viewModel.systemMonitor.cpuIdleString,
                        totalText: viewModel.systemMonitor.cpuTotalString
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 190)
                
                // Cleaning Section
                MaterialCard(title: "Sistem Temizliği") {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header with titles and status
                        HStack(alignment: .top, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sistem Temizliği")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Önbellek ve Gereksiz Dosyalar")
                                    .font(.title2)
                                    .bold()
                                Text("Chrome, Brave, Edge, Opera ve Sistem Logları.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: permissionVM.hasFullDiskAccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                Text(permissionVM.hasFullDiskAccess ? "Tam Disk Erişimi Verildi" : "Tam Disk Erişimi Gerekli")
                                    .font(.subheadline)
                            }
                            .foregroundStyle(permissionVM.hasFullDiskAccess ? Color.green : Color.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .adaptiveGlassEffect(in: .capsule)
                        }
                        
                        Divider()
                        
                        if permissionVM.hasFullDiskAccess {
                            VStack(alignment: .center, spacing: 12) {
                                Text("Tam Disk Erişimi")
                                    .font(.subheadline)
                                    .bold()
                                
                                Text("Tam Disk Erişimi verildiğinde DustBuster, sistem logları ve önbellek klasörlerine güvenli şekilde erişebilir. Bu yetkiyi dilediğiniz zaman Sistem Ayarları > Gizlilik ve Güvenlik > Tam Disk Erişimi bölümünden yönetebilirsiniz.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: 560)
                                
                                Button(action: {
                                    if permissionVM.hasFullDiskAccess {
                                        viewModel.scanSystem()
                                    } else {
                                        showFullDiskAccessAlert = true
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        if viewModel.isScanning {
                                            ProgressView()
                                                .scaleEffect(0.5)
                                        } else {
                                            Image(systemName: "magnifyingglass")
                                        }
                                        Text("Sistemi Tara")
                                    }
                                    .font(.headline)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                }
                                .adaptiveGlassButtonStyle(prominent: true)
                                .tint(.blue)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .disabled(viewModel.isScanning || viewModel.isCleaning || !permissionVM.hasFullDiskAccess)
                                .opacity(permissionVM.hasFullDiskAccess ? 1.0 : 0.5)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            VStack(alignment: .center, spacing: 12) {
                                VStack(alignment: .center, spacing: 8) {
                                    Text("Tam Disk Erişimi")
                                        .font(.subheadline)
                                        .bold()
                                    
                                    Text("Durum: İzin yok. Bazı loglar ve klasörler taranamayabilir. Bu yetkiyi Sistem Ayarları > Gizlilik ve Güvenlik > Tam Disk Erişimi bölümünden yönetebilir ve DustBuster’a dilediğiniz zaman verebilirsiniz.")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: 520)
                                }
                                .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    if permissionVM.hasFullDiskAccess {
                                        viewModel.scanSystem()
                                    } else {
                                        showFullDiskAccessAlert = true
                                    }
                                }) {
                                    HStack {
                                        if viewModel.isScanning {
                                            ProgressView()
                                                .scaleEffect(0.5)
                                        } else {
                                            Image(systemName: "magnifyingglass")
                                        }
                                        Text("Sistemi Tara")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                }
                                .adaptiveGlassButtonStyle(prominent: true)
                                .tint(.blue)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .disabled(viewModel.isScanning || viewModel.isCleaning || !permissionVM.hasFullDiskAccess)
                                .opacity(permissionVM.hasFullDiskAccess ? 1.0 : 0.5)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        if viewModel.lastTrashTransaction != nil {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Son Temizlik: \(viewModel.lastCleanedSize) Çöp Kutusu'na taşındı (boşaltılınca alan açılır).")
                                    .foregroundColor(.green)
                            }
                            .padding(.top, 5)
                        }
                    }
                }
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .sheet(isPresented: $viewModel.showCleanerReview) {
            CleanerReviewView(viewModel: viewModel)
        }
        .alert("Tam Disk Erişimi olmadan sistem temizliği yapılamaz.",
               isPresented: $showFullDiskAccessAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text("Ayarlar > Tam Disk Erişimi bölümünden DustBuster’a izin verin.")
        }
    }
}

struct UsageCard: View {
    let title: String
    let percentage: Double
    let primaryColor: Color
    let usedText: String
    let freeText: String
    let totalText: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            UsageRingView(percentage: percentage, primaryColor: primaryColor)
            
            UsageDetailsView(
                usedText: usedText,
                freeText: freeText,
                totalText: totalText
            )
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding()
        .adaptiveGlassEffect(in: .rect(cornerRadius: 16))
    }
}

struct UsageRingView: View {
    let percentage: Double
    let primaryColor: Color
    
    private let size: CGFloat = 96
    private let lineWidth: CGFloat = 12
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundColor(Color.gray.opacity(0.2))
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(max(percentage, 0.0), 1.0)))
                .stroke(
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .foregroundColor(primaryColor)
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear, value: percentage)
            
            Text(String(format: "%.0f%%", min(max(percentage, 0.0), 1.0) * 100.0))
                .font(.title2)
                .bold()
        }
        .frame(width: size, height: size)
    }
}

struct UsageDetailsView: View {
    let usedText: String
    let freeText: String
    let totalText: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(usedText)
            Text(freeText)
            Text(totalText)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
}

```

---

## FILE: CleanerApp/DashboardViewModel.swift

```swift
// Sources/ViewModels/DashboardViewModel.swift
import Foundation
import Combine

/// Dashboard ekranı için ViewModel
@MainActor
class DashboardViewModel: ObservableObject {
    // MARK: - Managers
    let systemMonitor = SystemMonitor()
    let cleanerManager = CleanerManager()
    let permissionManager = PermissionManager.shared
    
    // MARK: - System Stats
    @Published var ramUsage: Double = 0.0
    @Published var diskUsage: Double = 0.0
    @Published var cpuUsage: Double = 0.0
    
    // MARK: - Cleaning State
    @Published var cleaningPlan: CleaningPlan?
    @Published var cleaningResult: CleaningResult?
    @Published var isScanning: Bool = false
    @Published var isCleaning: Bool = false
    @Published var isRestoring: Bool = false
    @Published var isUndoing: Bool = false
    @Published var lastCleanedSize: String = "0 KB"
    @Published var trashHistory: [TrashHistoryEntry] = []
    @Published var restoreErrorMessage: String?
    @Published var lastTrashTransaction: CleanerManager.TrashTransaction?
    
    // MARK: - Navigation
    @Published var showCleanerReview: Bool = false
    @Published var showPermissionAlert: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init() {
        // SystemMonitor → DashboardViewModel bağlama
        systemMonitor.$memoryUsage
            .sink { [weak self] value in
                guard let self = self else { return }
                // Mevcut view update turunun dışına itiyoruz
                DispatchQueue.main.async {
                    self.ramUsage = value
                }
            }
            .store(in: &cancellables)
        
        systemMonitor.$diskUsage
            .sink { [weak self] value in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.diskUsage = value
                }
            }
            .store(in: &cancellables)
        
        systemMonitor.$cpuUsage
            .sink { [weak self] value in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.cpuUsage = value
                }
            }
            .store(in: &cancellables)
        
        // İzin kontrolü
        permissionManager.checkFullDiskAccess()
        permissionManager.$hasFullDiskAccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasAccess in
                self?.showPermissionAlert = !hasAccess
            }
            .store(in: &cancellables)

        trashHistory = cleanerManager.loadHistory()
    }
    
    // MARK: - Cleaning
    
    func scanSystem() {
        guard !isScanning else { return }
        isScanning = true
        cleaningPlan = nil
        cleaningResult = nil
        lastCleanedSize = "0 KB"
        
        cleanerManager.scan { [weak self] plan in
            guard let self = self else { return }
            self.cleaningPlan = plan
            self.isScanning = false
            self.showCleanerReview = true
            self.lastTrashTransaction = nil
        }
    }
    
    /// Sadece seçili item'ları temizler
    func cleanSelectedItems() {
        guard let plan = cleaningPlan, plan.hasSelection, !isCleaning else { return }
        
        isCleaning = true
        
        cleanerManager.apply(plan: plan) { [weak self] result in
            guard let self = self else { return }
            
            self.lastCleanedSize = ByteCountFormatter.string(
                fromByteCount: result.totalMovedBytes,
                countStyle: .file
            )
            self.isCleaning = false
            self.cleaningResult = result
            self.trashHistory = self.cleanerManager.loadHistory()
            self.lastTrashTransaction = self.cleanerManager.makeTransaction(from: result)

            if var updatedPlan = self.cleaningPlan {
                let movedIDs = Set(result.moved.map { $0.candidate.id })
                updatedPlan.candidates.removeAll { movedIDs.contains($0.id) }
                self.cleaningPlan = updatedPlan
            }
        }
    }

    func undoLastTransaction() {
        guard let transaction = lastTrashTransaction, !isUndoing else { return }
        isUndoing = true

        cleanerManager.undo(transaction: transaction) { [weak self] result in
            guard let self = self else { return }
            self.isUndoing = false
            switch result {
            case .success:
                self.lastTrashTransaction = nil
                self.lastCleanedSize = "0 KB"
                self.trashHistory = self.cleanerManager.loadHistory()
                self.cleaningResult = nil
            case .failure(let error):
                self.restoreErrorMessage = error.localizedDescription
            }
        }
    }

    func restore(entry: TrashHistoryEntry) {
        guard !isRestoring else { return }
        isRestoring = true
        cleanerManager.restore(entry: entry) { [weak self] result in
            guard let self = self else { return }
            self.isRestoring = false
            switch result {
            case .success:
                self.trashHistory = self.cleanerManager.loadHistory()
            case .failure(let error):
                self.restoreErrorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Selection Management

    func toggleSelection(for itemID: UUID) {
        guard var plan = cleaningPlan else { return }
        plan.toggleSelection(for: itemID)
        cleaningPlan = plan
    }
    
    func selectAllScannedItems() {
        guard var plan = cleaningPlan else { return }
        plan.selectAll()
        cleaningPlan = plan
    }
    
    func clearScannedSelection() {
        guard var plan = cleaningPlan else { return }
        plan.clearSelection()
        cleaningPlan = plan
    }
    
    func openSettings() {
        permissionManager.requestFullDiskAccess()
    }
    
    var totalScanSize: String {
        let total = cleaningPlan?.totalSize ?? 0
        return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }
    
    var selectedScanSize: String {
        let total = cleaningPlan?.selectedSize ?? 0
        return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }
}

```

---

## FILE: CleanerApp/FileItem.swift

```swift
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
        // MARK: - Safari Cache
        if path.contains("/com.apple.Safari") {
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
            let chromiumCacheTypes = ["Cache", "Code Cache", "GPUCache"]
            let lastComponent = url.lastPathComponent

            if chromiumCacheTypes.contains(lastComponent) {
                // Tarayıcı ismini path'ten çıkar
                let browserName = extractChromiumBrowserName(from: path)
                let cacheType = lastComponent == "GPUCache" ? "GPU Cache" : lastComponent
                return "\(browserName) \(cacheType)"
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

```

---

## FILE: CleanerApp/FullDiskAccessLockedView.swift

```swift
import SwiftUI

struct FullDiskAccessLockedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Tam Disk Erişimi gerekli")
                .font(.title)
                .bold()
            
            Text("DustBuster'ın sisteminizi analiz edebilmesi için macOS Ayarlar > Gizlilik ve Güvenlik > Tam Disk Erişimi bölümünden uygulamaya izin vermeniz gerekiyor.")
                .multilineTextAlignment(.center)
            
            Button("Ayarları Aç") {
                PermissionManager.openFullDiskAccessSettings()
            }
            
            Text("İzni verdikten sonra DustBuster'ı kapatıp yeniden açın.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
}

```

---

## FILE: CleanerApp/Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIconFile</key>
	<string></string>
	<key>CFBundleIconName</key>
	<string>AppIcon</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
	<key>CFBundleShortVersionString</key>
	<string>$(MARKETING_VERSION)</string>
	<key>CFBundleVersion</key>
	<string>$(CURRENT_PROJECT_VERSION)</string>
	<key>LSMinimumSystemVersion</key>
	<string>$(MACOSX_DEPLOYMENT_TARGET)</string>
	<key>NSAccentColorName</key>
	<string>AccentColor</string>
	<key>NSAppleEventsUsageDescription</key>
	<string>DustBuster, uygulamalari ve kalinti dosyalarini guvenli sekilde Cop Kutusu'na tasimak icin Finder'a erisim ister.</string>
	<key>NSHumanReadableCopyright</key>
	<string></string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
</dict>
</plist>

```

---

## FILE: CleanerApp/LargeFileItem.swift

```swift
// Sources/Models/LargeFileItem.swift
import Foundation

struct LargeFileItem: Identifiable {
    let id = UUID()
    let url: URL
    let size: Int64
    var isSelected: Bool = false

    var name: String {
        url.lastPathComponent
    }

    var path: String {
        url.path
    }

    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

```

---

## FILE: CleanerApp/LargeFileManager.swift

```swift
// Sources/Managers/LargeFileManager.swift
import Foundation

final class LargeFileManager {

    private let fileManager = FileManager.default
    private let searchRoots: [URL]
    private let permissionManager = PermissionManager.shared
    private let logManager = LogManager.shared

    init() {
        let home = fileManager.homeDirectoryForCurrentUser

        // Sadece güvenli, kullanıcı odaklı klasörler
        searchRoots = [
            home.appendingPathComponent("Desktop"),
            home.appendingPathComponent("Documents"),
            home.appendingPathComponent("Downloads"),
            home.appendingPathComponent("Movies"),
            home.appendingPathComponent("Music"),
            home.appendingPathComponent("Pictures")
        ]
    }

    /// 250 MB ve üzeri dosyaları bulur.
    func scan(minSize: Int64,
              completion: @escaping ([LargeFileItem]) -> Void) {

        permissionManager.checkFullDiskAccess()
        if permissionManager.hasFullDiskAccess == false {
            #if DEBUG
            print("Full Disk Access yok, LargeFileManager scan iptal edildi")
            #endif
            logManager.log("Büyük dosya taraması durduruldu: Full Disk Access yok", category: .audit, level: .warning)
            DispatchQueue.main.async {
                completion([])
            }
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [LargeFileItem] = []
            self.logManager.log("Büyük dosya taraması başladı", category: .performance, level: .info)

            for root in self.searchRoots {
                guard let enumerator = self.fileManager.enumerator(
                    at: root,
                    includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
                    options: [.skipsHiddenFiles, .skipsPackageDescendants]
                ) else { continue }

                for case let url as URL in enumerator {
                    do {
                        let values = try url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])

                        guard values.isRegularFile == true,
                              let fileSize = values.fileSize else {
                            continue
                        }

                        let size64 = Int64(fileSize)
                        if size64 >= minSize {
                            results.append(LargeFileItem(url: url,
                                                         size: size64,
                                                         isSelected: false))
                        }
                    } catch {
                        continue
                    }
                }
            }

            // Büyükten küçüğe sırala
            results.sort { $0.size > $1.size }
            let totalSize = results.reduce(Int64(0)) { $0 + $1.size }
            let sizeText = ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
            self.logManager.log("Büyük dosya taraması tamamlandı: \(results.count) kayıt, \(sizeText)", category: .performance, level: .info)

            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
}

```

---

## FILE: CleanerApp/LargeFilesView.swift

```swift
// Sources/Views/LargeFilesView.swift
import SwiftUI

struct LargeFilesView: View {
    @EnvironmentObject var viewModel: LargeFilesViewModel
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            controls
            fileList
            errorBanner
            footer
        }
        .padding()
        .alert("Seçili dosyaları silmek istiyor musun?",
               isPresented: $showDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                viewModel.deleteSelected()
            }
        } message: {
            Text("Dosyalar kalıcı olarak silinmez; macOS Çöp Kutusu'na taşınır.")
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Büyük Dosyalar")
                .font(.title)
                .bold()

            Text("250 MB ve üzerindeki dosyaları bulup silebilirsin.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Kontroller

    private var controls: some View {
        HStack {
            Text("Eşik: 250 MB ve üzeri")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Button {
                viewModel.scheduleScan()
            } label: {
                HStack(spacing: 6) {
                    if viewModel.isScanning {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text("Yeniden Tara")
                }
            }
            .disabled(viewModel.isScanning)
        }
    }

    // MARK: - File List

    private var fileList: some View {
        List {
            if viewModel.items.isEmpty {
                Section {
                    if viewModel.isScanning {
                        HStack(spacing: 8) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Tarama yapılıyor...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                    } else {
                        Text("250 MB ve üzerinde dosya bulunamadı.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 12)
                    }
                }
            } else {
                Section {
                    ForEach($viewModel.items) { $item in
                        FileRowView(item: $item)
                    }
                }
            }
        }
        .listStyle(.inset)
        .frame(minHeight: 200, maxHeight: 420)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Seçili dosya sayısı: \(viewModel.selectedCount)")
                    .font(.subheadline)

                Text("Toplam boyut: \(viewModel.selectedSizeString)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Seçilenleri Sil", systemImage: "trash")
            }
            .disabled(!viewModel.hasSelectedItems || viewModel.isDeleting)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Error Banner
    
    private var errorBanner: some View {
        Group {
            if !viewModel.deleteErrors.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Çöp Kutusu'na taşınamayan dosyalar:")
                        .font(.subheadline)
                        .foregroundColor(.red)
                    ForEach(viewModel.deleteErrors, id: \.self) { message in
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .truncationMode(.middle)
                    }
                }
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - File Row View

private struct FileRowView: View {
    @Binding var item: LargeFileItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "doc.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)

                Text(item.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.displaySize)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Toggle("", isOn: $item.isSelected)
                    .labelsHidden()
                    .toggleStyle(.checkbox)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

```

---

## FILE: CleanerApp/LargeFilesViewModel.swift

```swift
// Sources/ViewModels/LargeFilesViewModel.swift
import Foundation
import Combine

final class LargeFilesViewModel: ObservableObject {
    @Published var items: [LargeFileItem] = []
    @Published var isScanning: Bool = false
    @Published var isDeleting: Bool = false
    @Published var deleteErrors: [String] = []

    private let manager = LargeFileManager()
    private let permissionManager = PermissionManager.shared

    /// Tek eşik: 250 MB
    let minSize: Int64 = 250 * 1024 * 1024

    // View'dan güvenli şekilde çağrılan tarama
    func scheduleScan() {
        scan()
    }

    private func scan() {
        permissionManager.checkFullDiskAccess()
        guard permissionManager.hasFullDiskAccess else {
            #if DEBUG
            print("Full Disk Access yok, LargeFiles scan iptal edildi")
            #endif
            return
        }
        
        guard !isScanning else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.isScanning = true
        }

        manager.scan(minSize: minSize) { [weak self] newItems in
            // LargeFileManager zaten main thread'de completion çağırıyor
            guard let self = self else { return }
            self.items = newItems
            self.isScanning = false
        }
    }

    // MARK: - Seçim bilgileri

    var hasSelectedItems: Bool {
        items.contains(where: { $0.isSelected })
    }

    var selectedCount: Int {
        items.filter { $0.isSelected }.count
    }

    var selectedSize: Int64 {
        items.filter { $0.isSelected }.reduce(0) { $0 + $1.size }
    }

    var selectedSizeString: String {
        guard selectedSize > 0 else { return "0 B" }
        return ByteCountFormatter.string(fromByteCount: selectedSize,
                                         countStyle: .file)
    }

    // MARK: - Silme

    func deleteSelected() {
        permissionManager.checkFullDiskAccess()
        guard permissionManager.hasFullDiskAccess else {
            #if DEBUG
            print("Full Disk Access yok, LargeFiles delete iptal edildi")
            #endif
            return
        }
        
        guard !isDeleting else { return }

        let toDelete = items.filter { $0.isSelected }
        guard !toDelete.isEmpty else { return }

        isDeleting = true
        deleteErrors.removeAll()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let fm = FileManager.default
            var deletedIDs = Set<UUID>()
            var errors: [String] = []

            for item in toDelete {
                do {
                    try fm.trashItem(at: item.url, resultingItemURL: nil)
                    deletedIDs.insert(item.id)
                } catch {
                    let message = "\(item.path): Çöp Kutusu'na taşınamadı - \(error.localizedDescription)"
                    errors.append(message)
                }
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.items.removeAll { deletedIDs.contains($0.id) }
                self.deleteErrors.append(contentsOf: errors)
                self.isDeleting = false
            }
        }
    }
}

```

---

## FILE: CleanerApp/LogManager.swift

```swift
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

```

---

## FILE: CleanerApp/MainDetailRouter.swift

```swift
import SwiftUI

struct MainDetailRouter: View {
    let selection: SidebarItem?
    
    var body: some View {
        switch selection ?? .dashboard {
        case .dashboard:
            PermissionGate(requiresFullDiskAccess: true) {
                DashboardView()
            }
        case .processes:
            PermissionGate(requiresFullDiskAccess: true) {
                ProcessListView()
            }
        case .largeFiles:
            PermissionGate(requiresFullDiskAccess: true) {
                LargeFilesView()
            }
        case .uninstaller:
            PermissionGate(requiresFullDiskAccess: true) {
                UninstallerView()
            }
        case .settings:
            PermissionGate(requiresFullDiskAccess: false) {
                SettingsView()
            }
        }
    }
}

```

---

## FILE: CleanerApp/MaterialCard.swift

```swift
import SwiftUI
import AppKit

struct MaterialCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .adaptiveGlassEffect(in: .rect(cornerRadius: 16))
    }
}

extension View {
    func materialCard() -> some View {
        self.modifier(MaterialCardModifier())
    }
}

// A reusable card view component
struct MaterialCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            content
        }
        .materialCard()
    }
}

```

---

## FILE: CleanerApp/PermissionGate.swift

```swift
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

```

---

## FILE: CleanerApp/PermissionManager.swift

```swift
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

```

---

## FILE: CleanerApp/ProcessItem.swift

```swift
// Sources/Models/ProcessItem.swift
import Foundation

/// Görev yöneticisinde gösterilen süreç bilgisi.
struct ProcessItem: Identifiable, Hashable {
    let id = UUID()
    let pid: Int
    let name: String
    let bundleIdentifier: String?
    let isSystemProtected: Bool
}

```

---

## FILE: CleanerApp/ProcessListView.swift

```swift
// Sources/Views/ProcessListView.swift
import SwiftUI

/// Çalışan uygulamaları gösteren ve kapatan ekran.
struct ProcessListView: View {
    @StateObject var manager = ProcessManager()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            list
            Divider()
            footer
        }
        .frame(minWidth: 600, minHeight: 400)
        .padding()
        .onAppear {
            manager.refresh()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Çalışan Uygulamalar")
                    .font(.title2)
                    .bold()
                Text("Dock'ta görünen üçüncü parti uygulamaları buradan kapatabilirsin.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button {
                manager.refresh()
            } label: {
                Label("Yenile", systemImage: "arrow.clockwise")
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Liste

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if manager.processes.isEmpty {
                    Text("Şu anda listelenecek kullanıcı uygulaması yok.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                } else {
                    ForEach(manager.processes) { process in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(process.name)
                                    .fontWeight(.medium)
                                HStack(spacing: 8) {
                                    if let bundle = process.bundleIdentifier {
                                        Text(bundle)
                                    }
                                    Text("PID: \(process.pid)")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            Spacer()
                            if process.isSystemProtected {
                                Text("Sistem")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            } else {
                                HStack(spacing: 6) {
                                    Button {
                                        manager.terminate(process, force: false)
                                    } label: {
                                        Text("Kapat")
                                    }
                                    .buttonStyle(.bordered)

                                    Button {
                                        manager.terminate(process, force: true)
                                    } label: {
                                        Text("Zorla Kapat")
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        
                        Divider()
                    }
                }
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
                .font(.caption)
            VStack(alignment: .leading, spacing: 2) {
                Text("Kapat: Uygulamaya normal çıkış isteği gönderir (Cmd+Q ile aynı).")
                Text("Zorla Kapat: Uygulama yanıt vermiyorsa kullanılır; kaydedilmemiş veriler kaybolabilir.")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.top, 4)
    }
}

```

---

## FILE: CleanerApp/ProcessManager.swift

```swift
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

```

---

## FILE: CleanerApp/SafeDeleteService.swift

```swift
import Foundation
import AppKit

// MARK: - AppleScript Deletion Result

enum AppleScriptDeleteError: Error {
    case userCancelled
    case scriptError(code: Int, message: String)
    case unknownError(String)

    var localizedDescription: String {
        switch self {
        case .userCancelled:
            return "Kullanici islemi iptal etti"
        case .scriptError(let code, let message):
            return "AppleScript hatasi (kod \(code)): \(message)"
        case .unknownError(let message):
            return message
        }
    }

    var isUserCancelled: Bool {
        if case .userCancelled = self { return true }
        return false
    }
}

final class SafeDeleteService {
    struct Rules {
        let forbiddenPaths: [String]
        let isPathAllowed: (String) -> Bool
    }

    private let fileManager = FileManager.default
    private let logManager = LogManager.shared

    struct SimpleMoveResult {
        struct Moved {
            let original: URL
            let trashedURL: URL?
        }

        struct Skipped {
            let url: URL
            let reason: String
        }

        struct Failure {
            let url: URL
            let error: NSError
        }

        let moved: [Moved]
        let skipped: [Skipped]
        let failed: [Failure]
        let notes: [String]
    }

    func moveToTrash(plan: CleaningPlan, rules: Rules, completion: @escaping (CleaningResult) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var moved: [CleaningResult.MovedItem] = []
            var skipped: [CleaningCandidate] = []
            var failed: [CleaningCandidate] = []
            var movedBytes: Int64 = 0
            var notes: [String] = []

            for candidate in plan.selectedCandidates {
                let path = candidate.path

                guard rules.isPathAllowed(path) else {
                    skipped.append(candidate)
                    self.logManager.log("Skip \(candidate.displayName): izinli değil", category: .audit, level: .warning)
                    self.appendNote("Atlandı: \(candidate.displayName) - izinli değil", to: &notes)
                    continue
                }

                guard self.isForbidden(path: path, forbiddenRoots: rules.forbiddenPaths) == false else {
                    skipped.append(candidate)
                    self.logManager.log("Skip \(candidate.displayName): yasaklı path", category: .audit, level: .warning)
                    self.appendNote("Atlandı: \(candidate.displayName) - yasaklı konum", to: &notes)
                    continue
                }

                guard self.fileManager.fileExists(atPath: path) else {
                    skipped.append(candidate)
                    self.logManager.log("Skip \(candidate.displayName): artık mevcut değil", category: .audit, level: .warning)
                    self.appendNote("Atlandı: \(candidate.displayName) - mevcut değil", to: &notes)
                    continue
                }

                guard let currentIdentity = FileIdentitySnapshot(url: candidate.url) else {
                    skipped.append(candidate)
                    self.logManager.log("Skip \(candidate.displayName): kimlik alınamadı", category: .audit, level: .warning)
                    self.appendNote("Atlandı: \(candidate.displayName) - kimlik alınamadı", to: &notes)
                    continue
                }

                guard candidate.identity.isSymbolicLink == false, currentIdentity.isSymbolicLink == false else {
                    skipped.append(candidate)
                    self.logManager.log("Skip \(candidate.displayName): symlink tespit edildi", category: .audit, level: .warning)
                    self.appendNote("Atlandı: \(candidate.displayName) - symlink", to: &notes)
                    continue
                }

                guard currentIdentity.matches(candidate.identity) else {
                    skipped.append(candidate)
                    self.logManager.log("Skip \(candidate.displayName): kimlik değişti", category: .audit, level: .warning)
                    self.appendNote("Atlandı: \(candidate.displayName) - dosya değişti", to: &notes)
                    continue
                }

                do {
                    var trashedURL: NSURL?
                    try self.fileManager.trashItem(at: candidate.url, resultingItemURL: &trashedURL)
                    moved.append(.init(candidate: candidate, trashedURL: trashedURL as URL?))
                    movedBytes += candidate.size
                    if let trashed = trashedURL {
                        self.appendNote("Taşındı: \(candidate.displayName) -> \(trashed.path ?? "Trash")", to: &notes)
                    } else {
                        self.appendNote("Taşındı: \(candidate.displayName)", to: &notes)
                    }
                } catch {
                    failed.append(candidate)
                    let nsError = error as NSError
                    self.logManager.log("Çöp Kutusu hatası \(candidate.displayName) kod \(nsError.code)", category: .error, level: .error)
                    self.appendNote("Hata: \(candidate.displayName) - kod \(nsError.code)", to: &notes)
                }
            }

            let result = CleaningResult(
                moved: moved,
                skipped: skipped,
                failed: failed,
                totalMovedBytes: movedBytes,
                notes: Array(notes.prefix(5))
            )

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    /// Trash-only helper for fixed URL lists. Keeps operations inside the user's home directory.
    func moveToTrash(urls: [URL], allowedOutsideHome: [URL] = [], completion: @escaping (SimpleMoveResult) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let homePath = self.fileManager.homeDirectoryForCurrentUser.path
            var moved: [SimpleMoveResult.Moved] = []
            var skipped: [SimpleMoveResult.Skipped] = []
            var failed: [SimpleMoveResult.Failure] = []
            var notes: [String] = []
            let allowedExtraPaths = allowedOutsideHome.map { $0.standardizedFileURL.path }
            let forbiddenRoots = ["/System", "/Library", "/usr", "/bin", "/sbin"]

            for url in urls {
                let path = url.standardizedFileURL.path

                if !path.hasPrefix(homePath) {
                    let isAllowedExtra = allowedExtraPaths.contains { path.hasPrefix($0) }
                    let isForbidden = forbiddenRoots.contains { path.hasPrefix($0) }
                    if !isAllowedExtra || isForbidden {
                        skipped.append(.init(url: url, reason: "İzinli değil"))
                        self.appendNote("Atlandı: \(url.lastPathComponent) - izinli değil", to: &notes)
                        continue
                    }
                } else if forbiddenRoots.contains(where: { path.hasPrefix($0) }) {
                    skipped.append(.init(url: url, reason: "İzinli değil"))
                    self.appendNote("Atlandı: \(url.lastPathComponent) - izinli değil", to: &notes)
                    continue
                }

                guard self.fileManager.fileExists(atPath: path) else {
                    skipped.append(.init(url: url, reason: "Mevcut değil"))
                    self.appendNote("Atlandı: \(url.lastPathComponent) - mevcut değil", to: &notes)
                    continue
                }

                if let isSymlink = try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink, isSymlink == true {
                    skipped.append(.init(url: url, reason: "Symlink"))
                    self.appendNote("Atlandı: \(url.lastPathComponent) - symlink", to: &notes)
                    continue
                }

                do {
                    var trashedURL: NSURL?
                    try self.fileManager.trashItem(at: url, resultingItemURL: &trashedURL)
                    moved.append(.init(original: url, trashedURL: trashedURL as URL?))
                    if let trashed = trashedURL {
                        self.logManager.log("Çöp Kutusu: \(url.lastPathComponent) -> \(trashed.path ?? "Trash")", category: .cleanup, level: .info)
                        self.appendNote("Taşındı: \(url.lastPathComponent)", to: &notes)
                    } else {
                        self.logManager.log("Çöp Kutusu: \(url.lastPathComponent)", category: .cleanup, level: .info)
                        self.appendNote("Taşındı: \(url.lastPathComponent)", to: &notes)
                    }
                } catch {
                    let nsError = error as NSError
                    failed.append(.init(url: url, error: nsError))
                    self.logManager.log("Çöp Kutusu hatası \(url.lastPathComponent) kod \(nsError.code)", category: .error, level: .error)
                    self.appendNote("Hata: \(url.lastPathComponent) - kod \(nsError.code)", to: &notes)
                }
            }

            let result = SimpleMoveResult(
                moved: moved,
                skipped: skipped,
                failed: failed,
                notes: Array(notes.prefix(5))
            )

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    private func isForbidden(path: String, forbiddenRoots: [String]) -> Bool {
        forbiddenRoots.contains { path.hasPrefix($0) }
    }

    private func appendNote(_ text: String, to list: inout [String]) {
        guard list.count < 5 else { return }
        list.append(text)
    }

    // MARK: - AppleScript Based Deletion

    /// Escapes a path for use in AppleScript single-quoted strings
    private func escapePathForAppleScript(_ path: String) -> String {
        // Single quotes in AppleScript: escape by ending quote, adding escaped quote, starting new quote
        // 'path' -> 'path'\''with'\''quotes'
        return path.replacingOccurrences(of: "'", with: "'\\''")
    }

    /// Generates a unique trash destination name if file already exists in trash
    private func uniqueTrashDestination(for url: URL) -> String {
        let trashURL = fileManager.urls(for: .trashDirectory, in: .userDomainMask).first
            ?? fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".Trash")

        let fileName = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension

        var candidate = trashURL.appendingPathComponent(url.lastPathComponent)
        var counter = 2

        while fileManager.fileExists(atPath: candidate.path) {
            let newName = ext.isEmpty ? "\(fileName) \(counter)" : "\(fileName) \(counter).\(ext)"
            candidate = trashURL.appendingPathComponent(newName)
            counter += 1
        }

        return candidate.path
    }

    /// Tries to move a single file to trash using Finder AppleScript (no admin)
    func moveToTrashViaFinder(url: URL) -> Result<URL, AppleScriptDeleteError> {
        let escapedPath = escapePathForAppleScript(url.path)
        let script = """
        tell application "Finder"
            move POSIX file "\(escapedPath)" to trash
        end tell
        """

        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else {
            return .failure(.unknownError("AppleScript olusturulamadi"))
        }

        let _ = appleScript.executeAndReturnError(&error)

        if let error = error {
            let code = error[NSAppleScript.errorNumber] as? Int ?? -1
            let message = error[NSAppleScript.errorMessage] as? String ?? "Bilinmeyen hata"

            if code == -128 {
                return .failure(.userCancelled)
            }
            return .failure(.scriptError(code: code, message: message))
        }

        // Get trash URL
        let trashURL = fileManager.urls(for: .trashDirectory, in: .userDomainMask).first
            ?? fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".Trash")
        let trashedURL = trashURL.appendingPathComponent(url.lastPathComponent)

        return .success(trashedURL)
    }

    /// Moves files to trash with admin privileges using AppleScript (single password prompt)
    /// All protected files are moved in a single operation
    func moveToTrashWithAdminPrivileges(urls: [URL], completion: @escaping (Result<[URL], AppleScriptDeleteError>) -> Void) {
        guard !urls.isEmpty else {
            completion(.success([]))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(.failure(.unknownError("Service deallocated")))
                }
                return
            }

            // Build mv commands for all files
            var moveCommands: [String] = []
            var trashedURLs: [URL] = []

            for url in urls {
                let escapedSource = self.escapePathForAppleScript(url.path)
                let destPath = self.uniqueTrashDestination(for: url)
                let escapedDest = self.escapePathForAppleScript(destPath)

                moveCommands.append("mv '\(escapedSource)' '\(escapedDest)'")
                trashedURLs.append(URL(fileURLWithPath: destPath))
            }

            // Join all commands with && so they run sequentially
            let combinedCommand = moveCommands.joined(separator: " && ")

            let script = """
            do shell script "\(combinedCommand)" with administrator privileges
            """

            var error: NSDictionary?
            guard let appleScript = NSAppleScript(source: script) else {
                DispatchQueue.main.async {
                    completion(.failure(.unknownError("AppleScript olusturulamadi")))
                }
                return
            }

            let _ = appleScript.executeAndReturnError(&error)

            DispatchQueue.main.async {
                if let error = error {
                    let code = error[NSAppleScript.errorNumber] as? Int ?? -1
                    let message = error[NSAppleScript.errorMessage] as? String ?? "Bilinmeyen hata"

                    if code == -128 {
                        completion(.failure(.userCancelled))
                    } else {
                        completion(.failure(.scriptError(code: code, message: message)))
                    }
                } else {
                    completion(.success(trashedURLs))
                }
            }
        }
    }

    // MARK: - Smart Delete (Normal -> AppleScript Fallback)

    struct SmartMoveResult {
        struct Moved {
            let original: URL
            let trashedURL: URL?
            let usedAdminPrivileges: Bool
        }

        struct Skipped {
            let url: URL
            let reason: String
        }

        struct Failure {
            let url: URL
            let error: NSError
        }

        let moved: [Moved]
        let skipped: [Skipped]
        let failed: [Failure]
        let notes: [String]
        let userCancelled: Bool
    }

    /// Smart deletion: tries normal FileManager first, collects failures, then uses AppleScript with admin privileges
    /// for protected files (single password prompt for all protected files)
    func smartMoveToTrash(urls: [URL], allowedOutsideHome: [URL] = [], completion: @escaping (SmartMoveResult) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let homePath = self.fileManager.homeDirectoryForCurrentUser.path
            var moved: [SmartMoveResult.Moved] = []
            var skipped: [SmartMoveResult.Skipped] = []
            var failed: [SmartMoveResult.Failure] = []
            var needsAdminPrivileges: [URL] = []
            var notes: [String] = []
            let allowedExtraPaths = allowedOutsideHome.map { $0.standardizedFileURL.path }
            let forbiddenRoots = ["/System", "/Library", "/usr", "/bin", "/sbin"]

            // PHASE 1: Try normal deletion for each file
            for url in urls {
                let path = url.standardizedFileURL.path

                // Security checks
                if !path.hasPrefix(homePath) {
                    let isAllowedExtra = allowedExtraPaths.contains { path.hasPrefix($0) }
                    let isForbidden = forbiddenRoots.contains { path.hasPrefix($0) }
                    if !isAllowedExtra || isForbidden {
                        skipped.append(.init(url: url, reason: "Izinli degil"))
                        self.appendNote("Atlandi: \(url.lastPathComponent) - izinli degil", to: &notes)
                        continue
                    }
                } else if forbiddenRoots.contains(where: { path.hasPrefix($0) }) {
                    skipped.append(.init(url: url, reason: "Izinli degil"))
                    self.appendNote("Atlandi: \(url.lastPathComponent) - izinli degil", to: &notes)
                    continue
                }

                guard self.fileManager.fileExists(atPath: path) else {
                    skipped.append(.init(url: url, reason: "Mevcut degil"))
                    self.appendNote("Atlandi: \(url.lastPathComponent) - mevcut degil", to: &notes)
                    continue
                }

                if let isSymlink = try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink, isSymlink == true {
                    skipped.append(.init(url: url, reason: "Symlink"))
                    self.appendNote("Atlandi: \(url.lastPathComponent) - symlink", to: &notes)
                    continue
                }

                // Try normal deletion
                do {
                    var trashedURL: NSURL?
                    try self.fileManager.trashItem(at: url, resultingItemURL: &trashedURL)
                    moved.append(.init(original: url, trashedURL: trashedURL as URL?, usedAdminPrivileges: false))
                    self.logManager.log("Cop Kutusu: \(url.lastPathComponent)", category: .cleanup, level: .info)
                    self.appendNote("Tasindi: \(url.lastPathComponent)", to: &notes)
                } catch {
                    let nsError = error as NSError
                    // Permission denied or similar - needs admin privileges
                    if nsError.code == NSFileWriteNoPermissionError ||
                       nsError.code == 513 ||  // Operation not permitted
                       nsError.code == 1 {     // General error that might need elevation
                        needsAdminPrivileges.append(url)
                        self.logManager.log("Admin yetkisi gerekli: \(url.lastPathComponent) (kod \(nsError.code))", category: .audit, level: .info)
                    } else {
                        failed.append(.init(url: url, error: nsError))
                        self.logManager.log("Cop Kutusu hatasi \(url.lastPathComponent) kod \(nsError.code)", category: .error, level: .error)
                        self.appendNote("Hata: \(url.lastPathComponent) - kod \(nsError.code)", to: &notes)
                    }
                }
            }

            // PHASE 2: If there are files needing admin privileges, request elevation once
            guard !needsAdminPrivileges.isEmpty else {
                let result = SmartMoveResult(
                    moved: moved,
                    skipped: skipped,
                    failed: failed,
                    notes: Array(notes.prefix(5)),
                    userCancelled: false
                )
                DispatchQueue.main.async {
                    completion(result)
                }
                return
            }

            // Use AppleScript with admin privileges for protected files
            self.moveToTrashWithAdminPrivileges(urls: needsAdminPrivileges) { adminResult in
                switch adminResult {
                case .success(let trashedURLs):
                    for (index, url) in needsAdminPrivileges.enumerated() {
                        let trashedURL = index < trashedURLs.count ? trashedURLs[index] : nil
                        moved.append(.init(original: url, trashedURL: trashedURL, usedAdminPrivileges: true))
                        self.logManager.log("Cop Kutusu (admin): \(url.lastPathComponent)", category: .cleanup, level: .info)
                        self.appendNote("Tasindi (admin): \(url.lastPathComponent)", to: &notes)
                    }
                    let result = SmartMoveResult(
                        moved: moved,
                        skipped: skipped,
                        failed: failed,
                        notes: Array(notes.prefix(5)),
                        userCancelled: false
                    )
                    completion(result)

                case .failure(let error):
                    if error.isUserCancelled {
                        // User cancelled - mark admin files as skipped
                        for url in needsAdminPrivileges {
                            skipped.append(.init(url: url, reason: "Kullanici iptal etti"))
                        }
                        self.appendNote("Kullanici admin yetkisini iptal etti", to: &notes)
                        let result = SmartMoveResult(
                            moved: moved,
                            skipped: skipped,
                            failed: failed,
                            notes: Array(notes.prefix(5)),
                            userCancelled: true
                        )
                        completion(result)
                    } else {
                        // AppleScript error - mark as failed
                        for url in needsAdminPrivileges {
                            let nsError = NSError(
                                domain: "SafeDeleteService",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]
                            )
                            failed.append(.init(url: url, error: nsError))
                        }
                        self.appendNote("Admin silme hatasi: \(error.localizedDescription)", to: &notes)
                        let result = SmartMoveResult(
                            moved: moved,
                            skipped: skipped,
                            failed: failed,
                            notes: Array(notes.prefix(5)),
                            userCancelled: false
                        )
                        completion(result)
                    }
                }
            }
        }
    }
}

```

---

## FILE: CleanerApp/SettingsView.swift

```swift
// Sources/Views/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var permissionVM: AppPermissionViewModel
    
    // Uygulama sürümü (Info.plist'ten okur)
    private var appVersion: String {
        let version = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "1.0"
        
        let build = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? "1"
        
        return "Sürüm \(version) (Build \(build))"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Güvenlik ve İzinler
                MaterialCard(title: "Güvenlik ve İzinler") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DustBuster, sadece önbellek, log ve büyük geçici dosyaları temizler. Şifreler, tarayıcı geçmişi, yer işaretleri ve kişisel belgelerine dokunmaz.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: permissionVM.hasFullDiskAccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(permissionVM.hasFullDiskAccess ? .green : .orange)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tam Disk Erişimi")
                                    .font(.subheadline)
                                    .bold()
                                
                                Text(permissionVM.hasFullDiskAccess ? "Durum: İzin verildi" : "Durum: İzin yok")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text("Bazı klasörlere erişilemiyorsa Sistem Ayarları > Güvenlik ve Gizlilik > Tam Disk Erişimi bölümünden DustBuster’a izin verebilirsiniz.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            Spacer()
                            
                            Button("Ayarları Aç") {
                                PermissionManager.openFullDiskAccessSettings()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                
                // MARK: - Hakkında DustBuster
                MaterialCard(title: "Hakkında DustBuster") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("DustBuster")
                                    .font(.title3)
                                    .bold()
                                
                                Text("macOS için güvenli sistem temizleyici.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Geliştirici: Murat Onurcu", systemImage: "person.fill")
                                .font(.subheadline)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "envelope")
                                Link(
                                    "muratonurcu@outlook.com",
                                    destination: URL(string: "mailto:muratonurcu@outlook.com")!
                                )
                                .font(.subheadline)
                            }
                            
                            Text(appVersion)
                                .font(.subheadline)
                                .padding(.top, 4)
                            
                            Text("Tüm işlemler sadece bu cihazda çalışır; hiçbir dosya veya sistem bilgisi uzak sunuculara gönderilmez.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 4)
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Logları Dışa Aktar")
                                    .font(.subheadline)
                                    .bold()
                                
                                Text("Son 7 günün loglarını ve temel sistem bilgilerini cihazına kaydedebilirsin. Loglar sadece bu cihazda saklanır; otomatik gönderim yoktur.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Button("Logları Dışa Aktar") {
                                    LogManager.shared.exportLogs()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

```

---

## FILE: CleanerApp/SidebarItem.swift

```swift
// Sources/Views/SidebarItem.swift
import Foundation

enum SidebarItem: Hashable {
    case dashboard
    case processes      // Çalışan Uygulamalar
    case largeFiles     // Büyük Dosyalar
    case uninstaller    // Uygulama Kaldır
    case settings
}

```

---

## FILE: CleanerApp/SidebarView.swift

```swift
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

```

---

## FILE: CleanerApp/SystemMonitor.swift

```swift
// Sources/Managers/SystemMonitor.swift
import Foundation
import Combine
import Darwin

/// Manages system resource monitoring (RAM, Disk, CPU).
class SystemMonitor: ObservableObject {
    // Yüzde değerleri (0.0 – 1.0) – Gauge için
    @Published var memoryUsage: Double = 0.0
    @Published var diskUsage: Double = 0.0
    @Published var cpuUsage: Double = 0.0

    // RAM detayları (UI için hazır string'ler)
    @Published var memoryUsedString: String = "-"
    @Published var memoryFreeString: String = "-"
    @Published var memoryTotalString: String = "-"

    // Disk detayları
    @Published var diskUsedString: String = "-"
    @Published var diskFreeString: String = "-"
    @Published var diskTotalString: String = "-"

    // CPU detayları (çekirdek bazlı)
    @Published var cpuBusyCores: Int = 0
    @Published var cpuTotalCores: Int = 1
    @Published var cpuBusyString: String = "-"   // "Meşgul: X çekirdek"
    @Published var cpuIdleString: String = "-"   // "Boşta: Y çekirdek"
    @Published var cpuTotalString: String = "-"  // "Toplam: Z çekirdek"

    private var timer: Timer?
    
    // CPU delta hesaplaması için önceki tick değerleri (core bazlı)
    private var previousCPUTicks: [(user: UInt64, system: UInt64, idle: UInt64, nice: UInt64)]?
    
    // ByteCountFormatter - tutarlı birim için
    private let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file  // GB (1000 bazlı, Finder ile uyumlu)
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter
    }()
    
    init() {
        cpuTotalCores = ProcessInfo.processInfo.activeProcessorCount
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        // 2 saniyede bir güncelle
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }
        updateMetrics() // İlk değer
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateMetrics() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let (memPercent, memUsed, memTotal) = self.getMemoryUsage()
            let (diskPercent, diskUsed, diskTotal) = self.getDiskUsage()
            let (cpuPercent, busyCores, totalCores) = self.getCPUUsage()
            
            let memFree = max(memTotal - memUsed, 0)
            let diskFree = max(diskTotal - diskUsed, 0)
            
            // Tutarlı formatlama
            let memUsedStr  = self.byteFormatter.string(fromByteCount: memUsed)
            let memFreeStr  = self.byteFormatter.string(fromByteCount: memFree)
            let memTotalStr = self.byteFormatter.string(fromByteCount: memTotal)
            
            let diskUsedStr  = self.byteFormatter.string(fromByteCount: diskUsed)
            let diskFreeStr  = self.byteFormatter.string(fromByteCount: diskFree)
            let diskTotalStr = self.byteFormatter.string(fromByteCount: diskTotal)
            
            // CPU çekirdek string'leri (3 satır, diğer kartlarla tutarlı)
            let idleCores = totalCores - busyCores
            let cpuBusyStr  = "Meşgul: \(busyCores) çekirdek"
            let cpuIdleStr  = "Boşta: \(idleCores) çekirdek"
            let cpuTotalStr = "Toplam: \(totalCores) çekirdek"
            
            DispatchQueue.main.async {
                // Gauge yüzdeleri
                self.memoryUsage = memPercent
                self.diskUsage   = diskPercent
                self.cpuUsage    = cpuPercent

                // RAM string'leri
                self.memoryUsedString  = memUsedStr
                self.memoryFreeString  = memFreeStr
                self.memoryTotalString = memTotalStr

                // Disk string'leri
                self.diskUsedString  = diskUsedStr
                self.diskFreeString  = diskFreeStr
                self.diskTotalString = diskTotalStr

                // CPU değerleri
                self.cpuBusyCores   = busyCores
                self.cpuTotalCores  = totalCores
                self.cpuBusyString  = cpuBusyStr
                self.cpuIdleString  = cpuIdleStr
                self.cpuTotalString = cpuTotalStr
            }
        }
    }
    
    // MARK: - Memory Usage
    /// Dönen değer: (yüzde, kullanılan byte, toplam byte)
    /// Activity Monitor ile uyumlu: Active + Wired + Compressed
    private func getMemoryUsage() -> (Double, Int64, Int64) {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        let totalBytes = Int64(ProcessInfo.processInfo.physicalMemory)

        if result == KERN_SUCCESS {
            let pageSize = UInt64(vm_kernel_page_size)

            // Activity Monitor ile uyumlu hesaplama
            let active     = UInt64(stats.active_count) * pageSize
            let wired      = UInt64(stats.wire_count) * pageSize
            let compressed = UInt64(stats.compressor_page_count) * pageSize

            // Used = Active + Wired + Compressed (Activity Monitor formülü)
            let used = active + wired + compressed

            let usedBytes = Int64(used)
            let percent = totalBytes > 0 ? Double(used) / Double(totalBytes) : 0.0
            return (min(max(percent, 0.0), 1.0), usedBytes, totalBytes)
        }

        return (0.0, 0, totalBytes)
    }
    
    // MARK: - Disk Usage
    /// Dönen değer: (yüzde, kullanılan byte, toplam byte)
    /// Finder ile uyumlu: Purgeable space dahil
    private func getDiskUsage() -> (Double, Int64, Int64) {
        let fileURL = URL(fileURLWithPath: "/")
        do {
            let values = try fileURL.resourceValues(forKeys: [
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityForImportantUsageKey
            ])

            if let total = values.volumeTotalCapacity,
               let available = values.volumeAvailableCapacityForImportantUsage {
                let totalInt64 = Int64(total)
                let used = totalInt64 - available
                let percent = totalInt64 > 0 ? Double(used) / Double(totalInt64) : 0.0
                return (min(max(percent, 0.0), 1.0), used, totalInt64)
            }
        } catch {
            print("Error retrieving disk usage: \(error)")
        }
        return (0.0, 0, 0)
    }
    
    // MARK: - CPU Usage (host_processor_info ile gerçek kullanım)
    /// Dönen değer: (yüzde 0-1, meşgul çekirdek sayısı, toplam çekirdek sayısı)
    private func getCPUUsage() -> (Double, Int, Int) {
        var numCPUs: natural_t = 0
        var cpuInfo: processor_info_array_t?
        var numCPUInfo: mach_msg_type_number_t = 0
        
        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numCPUs,
            &cpuInfo,
            &numCPUInfo
        )
        
        guard result == KERN_SUCCESS, let info = cpuInfo else {
            return (0.0, 0, ProcessInfo.processInfo.activeProcessorCount)
        }
        
        defer {
            // Belleği serbest bırak
            let size = vm_size_t(numCPUInfo) * vm_size_t(MemoryLayout<integer_t>.size)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: info), size)
        }
        
        let coreCount = Int(numCPUs)
        var currentTicks: [(user: UInt64, system: UInt64, idle: UInt64, nice: UInt64)] = []
        
        // Her çekirdek için tick değerlerini oku
        for i in 0..<coreCount {
            let offset = Int32(i) * CPU_STATE_MAX
            let user   = UInt64(info[Int(offset + CPU_STATE_USER)])
            let system = UInt64(info[Int(offset + CPU_STATE_SYSTEM)])
            let idle   = UInt64(info[Int(offset + CPU_STATE_IDLE)])
            let nice   = UInt64(info[Int(offset + CPU_STATE_NICE)])
            currentTicks.append((user, system, idle, nice))
        }
        
        // İlk çağrıda önceki değer yoksa 0% göster
        guard let prevTicks = previousCPUTicks, prevTicks.count == coreCount else {
            previousCPUTicks = currentTicks
            return (0.0, 0, coreCount)
        }
        
        // Her çekirdek için kullanım hesapla
        var totalUsage: Double = 0.0
        var busyCores = 0
        let busyThreshold = 0.10  // %10 eşik
        
        for i in 0..<coreCount {
            let prev = prevTicks[i]
            let curr = currentTicks[i]
            
            let deltaUser   = curr.user - prev.user
            let deltaSystem = curr.system - prev.system
            let deltaIdle   = curr.idle - prev.idle
            let deltaNice   = curr.nice - prev.nice
            
            let deltaTotal = deltaUser + deltaSystem + deltaIdle + deltaNice
            let deltaUsed  = deltaUser + deltaSystem + deltaNice  // idle hariç
            
            var coreUsage: Double = 0.0
            if deltaTotal > 0 {
                coreUsage = Double(deltaUsed) / Double(deltaTotal)
            }
            
            totalUsage += coreUsage
            
            if coreUsage >= busyThreshold {
                busyCores += 1
            }
        }
        
        // Önceki değerleri güncelle
        previousCPUTicks = currentTicks
        
        // Ortalama CPU kullanımı
        let avgUsage = coreCount > 0 ? totalUsage / Double(coreCount) : 0.0
        
        return (min(max(avgUsage, 0.0), 1.0), busyCores, coreCount)
    }
}

```

---

## FILE: CleanerApp/TrashHistoryStore.swift

```swift
import Foundation

struct TrashHistoryEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let originalURL: URL
    let trashedURL: URL
    let timestamp: Date
    let size: Int64?
    let displayName: String

    init(id: UUID = UUID(), originalURL: URL, trashedURL: URL, timestamp: Date = Date(), size: Int64?, displayName: String) {
        self.id = id
        self.originalURL = originalURL
        self.trashedURL = trashedURL
        self.timestamp = timestamp
        self.size = size
        self.displayName = displayName
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var formattedSize: String {
        guard let size else { return "-" }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

final class TrashHistoryStore {
    static let shared = TrashHistoryStore()

    private let defaults = UserDefaults.standard
    private let key = "DustBuster.TrashHistory"
    private let maxEntries = 50
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "DustBuster.TrashHistoryStore")

    private init() {}

    func load() -> [TrashHistoryEntry] {
        guard let data = defaults.data(forKey: key),
              let entries = try? decoder.decode([TrashHistoryEntry].self, from: data) else {
            return []
        }
        return entries
    }

    func save(_ entries: [TrashHistoryEntry]) {
        guard let data = try? encoder.encode(entries) else { return }
        defaults.set(data, forKey: key)
    }

    func append(_ newEntries: [TrashHistoryEntry]) -> [TrashHistoryEntry] {
        queue.sync {
            var current = load()
            current.insert(contentsOf: newEntries, at: 0)
            if current.count > maxEntries {
                current = Array(current.prefix(maxEntries))
            }
            save(current)
            return current
        }
    }

    @discardableResult
    func remove(_ id: UUID) -> [TrashHistoryEntry] {
        queue.sync {
            var current = load()
            current.removeAll { $0.id == id }
            save(current)
            return current
        }
    }

    @discardableResult
    func remove(trashedPaths: Set<String>) -> [TrashHistoryEntry] {
        queue.sync {
            var current = load()
            current.removeAll { trashedPaths.contains($0.trashedURL.standardizedFileURL.path) }
            save(current)
            return current
        }
    }
}

```

---

## FILE: CleanerApp/UninstallerManager.swift

```swift
import Foundation

enum UninstallItemKind: String {
    case appBundle = "Uygulama Paketi"
    case applicationSupport = "Application Support"
    case caches = "Caches"
    case preferences = "Preferences"
    case preferencesByHost = "Preferences (ByHost)"
    case logs = "Logs"
    case savedState = "Saved Application State"
    case containers = "Containers"
    case groupContainers = "Group Containers"
    case launchAgents = "Launch Agents"
    case httpStorages = "HTTP Storages"
    case webKit = "WebKit"
    case cookies = "Cookies"
    case crashReports = "Crash Reports"
    case applicationScripts = "Application Scripts"
    case internetPlugins = "Internet Plug-Ins"
    case preferencePanes = "Preference Panes"
    case quickLook = "QuickLook"
    case screenSavers = "Screen Savers"
    case services = "Services"
    case spotlight = "Spotlight"
    case inputMethods = "Input Methods"
    case frameworks = "Frameworks"
    case colorPickers = "Color Pickers"
    case addressBookPlugins = "Address Book Plug-Ins"
    // Ek kullanici konumlari
    case mailBundles = "Mail Bundles"
    case developer = "Developer"
    // Sistem seviyesi konumlar (/Library/)
    case systemAppSupport = "System Application Support"
    case systemLaunchAgents = "System Launch Agents"
    case systemLaunchDaemons = "System Launch Daemons"
    case privilegedHelpers = "Privileged Helper Tools"
    case systemPreferences = "System Preferences"
    case systemFrameworks = "System Frameworks"
    case recentDocuments = "Recent Documents"
    case other = "Diger"
}

// MARK: - Search Terms Structure

struct SearchTerms {
    let exact: [String]
    let prefix: [String]
    let contains: [String]
    
    func matches(_ name: String) -> Bool {
        let nameLower = name.lowercased()
        
        for exact in exact {
            let exactLower = exact.lowercased()
            if nameLower == exactLower ||
               nameLower.hasPrefix(exactLower + ".") ||
               nameLower.hasSuffix("." + exactLower) ||
               nameLower.contains(".\(exactLower).") {
                return true
            }
        }
        
        for prefix in prefix {
            if nameLower.hasPrefix(prefix.lowercased()) {
                return true
            }
        }
        
        for term in contains where term.count >= 3 {
            if nameLower.contains(term.lowercased()) {
                return true
            }
        }
        
        return false
    }
    
    func matchesStrict(_ name: String) -> Bool {
        let nameLower = name.lowercased()
        
        for exact in exact {
            let exactLower = exact.lowercased()
            if nameLower == exactLower ||
               nameLower.hasPrefix(exactLower + ".") ||
               nameLower.contains(exactLower) {
                return true
            }
        }
        
        for prefix in prefix {
            if nameLower.hasPrefix(prefix.lowercased()) {
                return true
            }
        }
        
        return false
    }
}

struct UninstallItem: Identifiable {
    let id = UUID()
    let url: URL
    let displayName: String
    let kind: UninstallItemKind
    let note: String
    let sizeBytes: Int64?
    var isSelected: Bool
}

/// Scans for leftover files related to an app under ~/Library and prepares uninstall items.
final class UninstallerManager {
    private let fileManager = FileManager.default
    private let homeLibrary: URL
    private let systemLibrary: URL
    private let home: URL

    /// Sistem seviyesi konumlari da taramak icin true yap (/Library/)
    var includeSystemLocations: Bool = false

    init() {
        home = fileManager.homeDirectoryForCurrentUser
        homeLibrary = home.appendingPathComponent("Library")
        systemLibrary = URL(fileURLWithPath: "/Library")
    }

    func buildItems(appURL: URL, bundleId: String?, appName: String) -> [UninstallItem] {
        var items: [UninstallItem] = []
        var seenPaths: Set<String> = []

        // 1. Uygulama paketi
        if let appItem = makeAppBundleItem(appURL: appURL) {
            items.append(appItem)
            seenPaths.insert(appURL.path)
        }

        // 2. Arama terimleri oluştur
        let searchTerms = buildSearchTerms(bundleId: bundleId, appName: appName, appURL: appURL)
        
        // 3. Tüm arama konumlarını tara
        let candidates = findAllCandidates(searchTerms: searchTerms, bundleId: bundleId, appName: appName, appURL: appURL)
        
        for candidate in candidates {
            let path = candidate.url.path
            guard !seenPaths.contains(path) else { continue }
            seenPaths.insert(path)
            
            guard let item = buildItem(for: candidate) else { continue }
            items.append(item)
        }

        // Boyuta göre sırala (büyükten küçüğe)
        items.sort { ($0.sizeBytes ?? 0) > ($1.sizeBytes ?? 0) }
        
        return items
    }

    // MARK: - Search Terms

    private func buildSearchTerms(bundleId: String?, appName: String, appURL: URL) -> SearchTerms {
        var exactTerms: [String] = []
        var prefixTerms: [String] = []
        var containsTerms: [String] = []
        
        if let bundleId = bundleId {
            exactTerms.append(bundleId)
            
            let parts = bundleId.split(separator: ".")
            if parts.count >= 2 {
                let prefix = parts.prefix(2).joined(separator: ".")
                prefixTerms.append(prefix)
                
                if let company = parts.dropFirst().first {
                    containsTerms.append(String(company))
                }
                if let appPart = parts.last {
                    containsTerms.append(String(appPart))
                }
            }
            
            // Helper app patterns
            let helperSuffixes = [".helper", ".Helper", ".agent", ".Agent", ".updater", ".Updater",
                                 ".Launcher", ".launcher", ".CrashHandler", ".InstallHelper",
                                 ".LoginHelper", ".ServiceHelper", ".xpc"]
            for suffix in helperSuffixes {
                exactTerms.append(bundleId + suffix)
            }
        }
        
        containsTerms.append(appName)
        containsTerms.append(appName.replacingOccurrences(of: " ", with: ""))
        containsTerms.append(appName.replacingOccurrences(of: " ", with: "-"))
        containsTerms.append(appName.replacingOccurrences(of: " ", with: "_"))
        
        if let executableName = getExecutableName(from: appURL), executableName != appName {
            containsTerms.append(executableName)
        }
        
        let fileNameWithoutExt = appURL.deletingPathExtension().lastPathComponent
        if fileNameWithoutExt != appName {
            containsTerms.append(fileNameWithoutExt)
        }
        
        if let developerName = getDeveloperName(from: appURL) {
            containsTerms.append(developerName)
        }
        
        let lowercaseContains = containsTerms.map { $0.lowercased() }
        
        return SearchTerms(
            exact: Array(Set(exactTerms)).filter { !$0.isEmpty },
            prefix: Array(Set(prefixTerms)).filter { !$0.isEmpty },
            contains: Array(Set(containsTerms + lowercaseContains)).filter { !$0.isEmpty && $0.count > 2 }
        )
    }

    // MARK: - Candidate Finding

    private struct Candidate {
        let url: URL
        let kind: UninstallItemKind
        let note: String
    }

    private func findAllCandidates(searchTerms: SearchTerms, bundleId: String?, appName: String, appURL: URL) -> [Candidate] {
        var candidates: [Candidate] = []
        
// Arama konumlari ve turleri (27 farkli kullanici konumu)
        let searchLocations: [(String, UninstallItemKind, Bool)] = [
            // Temel konumlar
            ("Application Support", .applicationSupport, true),  // recursive
            ("Caches", .caches, true),
            ("Preferences", .preferences, false),
            ("Logs", .logs, true),
            ("Saved Application State", .savedState, false),
            ("Containers", .containers, false),
            ("Group Containers", .groupContainers, true),
            ("LaunchAgents", .launchAgents, false),
            ("HTTPStorages", .httpStorages, false),
            ("WebKit", .webKit, true),
            ("Cookies", .cookies, false),
            ("Application Scripts", .applicationScripts, false),
            ("Caches/com.apple.nsurlsessiond/Downloads", .caches, true),
            // Ek konumlar (AppCleaner seviyesi)
            ("Internet Plug-Ins", .internetPlugins, false),
            ("PreferencePanes", .preferencePanes, false),
            ("QuickLook", .quickLook, false),
            ("Screen Savers", .screenSavers, false),
            ("Services", .services, false),
            ("Spotlight", .spotlight, false),
            ("Input Methods", .inputMethods, false),
            ("Frameworks", .frameworks, true),
            ("ColorPickers", .colorPickers, false),
            ("Address Book Plug-Ins", .addressBookPlugins, false),
            // Ek kullanici konumlari
            ("Mail/Bundles", .mailBundles, false),
            ("Developer", .developer, true),
            ("Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments", .recentDocuments, false),
        ]
        
        for (subpath, kind, recursive) in searchLocations {
            let dirURL = homeLibrary.appendingPathComponent(subpath)
            guard fileManager.fileExists(atPath: dirURL.path) else { continue }
            
            let found = searchDirectory(
                at: dirURL,
                searchTerms: searchTerms,
                kind: kind,
                recursive: recursive,
                maxDepth: recursive ?3 : 1
            )
            candidates.append(contentsOf: found)
        }
        
        // Preferences/ByHost ozel arama
        let byHostCandidates = searchByHost(searchTerms: searchTerms)
        candidates.append(contentsOf: byHostCandidates)

        // Crash Reports
        let crashCandidates = searchCrashReports(searchTerms: searchTerms)
        candidates.append(contentsOf: crashCandidates)

        // Embedded helper app'lerin kalıntılarını ara
        let helperCandidates = findEmbeddedHelperApps(appURL: appURL, baseTerms: searchTerms)
        candidates.append(contentsOf: helperCandidates)
        
        // Installer receipts
        let receiptCandidates = searchInstallerReceipts(searchTerms: searchTerms, bundleId: bundleId)
        candidates.append(contentsOf: receiptCandidates)

        // Sistem seviyesi konumlar (sadece includeSystemLocations true ise)
        if includeSystemLocations {
            let systemCandidates = searchSystemLocations(searchTerms: searchTerms)
            candidates.append(contentsOf: systemCandidates)
        }

        return candidates
    }

    private func searchDirectory(
        at url: URL,
        searchTerms: SearchTerms,
        kind: UninstallItemKind,
        recursive: Bool,
        maxDepth: Int,
        currentDepth: Int = 0
    ) -> [Candidate] {
        var results: [Candidate] = []
        
        guard currentDepth < maxDepth else { return results }
        guard isInsideHomeLibrary(url) else { return results }
        
        guard let contents = try? fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey],
            options: [.skipsHiddenFiles]
        ) else { return results }
        
        for itemURL in contents {
            // Symlink atla
            if isSymlink(itemURL) { continue }
            
            let itemName = itemURL.lastPathComponent
            let itemNameLower = itemName.lowercased()
            
            // Eşleşme kontrolü
            let matches = searchTerms.matches(itemName)
            
            if matches {
                results.append(Candidate(
                    url: itemURL,
                    kind: kind,
                    note: url.lastPathComponent
                ))
            } else if recursive {
                // Alt klasörleri tara
                let isDir = (try? itemURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                if isDir {
                    let subResults = searchDirectory(
                        at: itemURL,
                        searchTerms: searchTerms,
                        kind: kind,
                        recursive: true,
                        maxDepth: maxDepth,
                        currentDepth: currentDepth + 1
                    )
                    results.append(contentsOf: subResults)
                }
            }
        }
        
        return results
    }

    private func searchByHost(searchTerms: SearchTerms) -> [Candidate] {
        let byHostDir = homeLibrary.appendingPathComponent("Preferences/ByHost")
        guard let contents = try? fileManager.contentsOfDirectory(
            at: byHostDir,
            includingPropertiesForKeys: [.isSymbolicLinkKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        
        return contents.compactMap { url -> Candidate? in
            guard !isSymlink(url) else { return nil }
            let name = url.lastPathComponent.lowercased()
            let matches = searchTerms.matches(name)
            guard matches else { return nil }
            
            return Candidate(
                url: url,
                kind: .preferencesByHost,
                note: "Preferences/ByHost"
            )
        }
    }

    private func searchCrashReports(searchTerms: SearchTerms) -> [Candidate] {
        var results: [Candidate] = []
        
        let crashDirs = [
            homeLibrary.appendingPathComponent("Logs/DiagnosticReports"),
            homeLibrary.appendingPathComponent("Logs/CrashReporter")
        ]
        
        for crashDir in crashDirs {
            guard let contents = try? fileManager.contentsOfDirectory(
                at: crashDir,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else { continue }
            
            for url in contents {
                let name = url.lastPathComponent.lowercased()
                let matches = searchTerms.matches(name)
                if matches {
                    results.append(Candidate(
                        url: url,
                        kind: .crashReports,
                        note: crashDir.lastPathComponent
                    ))
                }
            }
        }
        
        return results
    }

    // MARK: - System Locations Search

    /// /Library/ altindaki sistem seviyesi konumlari tarar
    /// Guvenlik: /System/, /usr/, /bin/, /sbin/, /private/ (receipts haric) ASLA taranmaz
    private func searchSystemLocations(searchTerms: SearchTerms) -> [Candidate] {
        var results: [Candidate] = []

        // Sistem seviyesi konumlar (/Library/ altinda)
        let systemLocations: [(String, UninstallItemKind, Bool)] = [
            ("Application Support", .systemAppSupport, true),
            ("LaunchAgents", .systemLaunchAgents, false),
            ("LaunchDaemons", .systemLaunchDaemons, false),
            ("PrivilegedHelperTools", .privilegedHelpers, false),
            ("Preferences", .systemPreferences, false),
            ("Frameworks", .systemFrameworks, true),
        ]

        for (subpath, kind, recursive) in systemLocations {
            let dirURL = systemLibrary.appendingPathComponent(subpath)
            guard fileManager.fileExists(atPath: dirURL.path) else { continue }

            let found = searchSystemDirectory(
                at: dirURL,
                searchTerms: searchTerms,
                kind: kind,
                recursive: recursive,
                maxDepth: recursive ? 2 : 1
            )
            results.append(contentsOf: found)
        }

        return results
    }

    /// Sistem dizinlerini tarar - homeLibrary yerine systemLibrary kontrolu yapar
    private func searchSystemDirectory(
        at url: URL,
        searchTerms: SearchTerms,
        kind: UninstallItemKind,
        recursive: Bool,
        maxDepth: Int,
        currentDepth: Int = 0
    ) -> [Candidate] {
        var results: [Candidate] = []

        guard currentDepth < maxDepth else { return results }

        // Guvenlik kontrolleri - bu konumlari ASLA tarama
        let path = url.path
        let forbiddenPrefixes = ["/System", "/usr", "/bin", "/sbin", "/private"]

        // Eger path yasakli bir prefix ile basliyorsa atla
        for forbidden in forbiddenPrefixes {
            if path.hasPrefix(forbidden) {
                return results
            }
        }

        // Sadece /Library altini tara (tek izinli konum)
        guard path.hasPrefix("/Library") else { return results }

        guard let contents = try? fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey],
            options: [.skipsHiddenFiles]
        ) else { return results }

        for itemURL in contents {
            // Symlink atla
            if isSymlink(itemURL) { continue }

            let itemName = itemURL.lastPathComponent
            let itemNameLower = itemName.lowercased()

            // Eslesme kontrolu
            let matches = searchTerms.matchesStrict(itemName)

            if matches {
                results.append(Candidate(
                    url: itemURL,
                    kind: kind,
                    note: "/Library/\(url.lastPathComponent)"
                ))
            } else if recursive {
                // Alt klasorleri tara
                let isDir = (try? itemURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                if isDir {
                    let subResults = searchSystemDirectory(
                        at: itemURL,
                        searchTerms: searchTerms,
                        kind: kind,
                        recursive: true,
                        maxDepth: maxDepth,
                        currentDepth: currentDepth + 1
                    )
                    results.append(contentsOf: subResults)
                }
            }
        }

        return results
    }

    // MARK: - Item Building

    private func makeAppBundleItem(appURL: URL) -> UninstallItem? {
        if isSymlink(appURL) { return nil }

        let size = sizeOfItem(at: appURL, allowOutsideHome: true)
        return UninstallItem(
            url: appURL,
            displayName: appURL.lastPathComponent,
            kind: .appBundle,
            note: "Uygulama Paketi",
            sizeBytes: size,
            isSelected: true
        )
    }

    private func buildItem(for candidate: Candidate) -> UninstallItem? {
        // Hem ~/Library hem de /Library izinli
        let isValidLocation = isInsideHomeLibrary(candidate.url) || isInsideSystemLibrary(candidate.url)
        guard isValidLocation else { return nil }
        guard fileManager.fileExists(atPath: candidate.url.path) else { return nil }
        guard !isSymlink(candidate.url) else { return nil }

        // Sistem dosyalari icin allowOutsideHome true olmali
        let isSystemFile = isInsideSystemLibrary(candidate.url)
        let size = sizeOfItem(at: candidate.url, allowOutsideHome: isSystemFile)
        return UninstallItem(
            url: candidate.url,
            displayName: candidate.url.lastPathComponent,
            kind: candidate.kind,
            note: candidate.note,
            sizeBytes: size,
            isSelected: true
        )
    }

    // MARK: - Size Calculation

    private func sizeOfItem(at url: URL, allowOutsideHome: Bool) -> Int64? {
        let standardized = url.standardizedFileURL
        if !allowOutsideHome && !standardized.path.hasPrefix(home.path) {
            return nil
        }

        let keys: Set<URLResourceKey> = [
            .isDirectoryKey,
            .isSymbolicLinkKey,
            .totalFileAllocatedSizeKey,
            .fileAllocatedSizeKey,
            .totalFileSizeKey,
            .fileSizeKey
        ]

        guard let values = try? standardized.resourceValues(forKeys: keys) else { return nil }
        if values.isSymbolicLink == true { return nil }

        if values.isDirectory == true {
            return sizeOfDirectory(at: standardized, keys: keys)
        } else {
            return fileSize(from: values)
        }
    }

    private func sizeOfDirectory(at url: URL, keys: Set<URLResourceKey>) -> Int64 {
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: Array(keys),
            options: [],
            errorHandler: nil
        ) else { return 0 }

        var total: Int64 = 0

        for case let fileURL as URL in enumerator {
            // Symlink kontrolü
            if isSymlink(fileURL) {
                enumerator.skipDescendants()
                continue
            }

            guard let values = try? fileURL.resourceValues(forKeys: keys) else { continue }
            
            // Sadece dosyaları say
            if values.isDirectory == true { continue }
            
            total += fileSize(from: values)
        }

        return total
    }

    private func fileSize(from values: URLResourceValues) -> Int64 {
        // Allocated size daha doğru (disk üzerindeki gerçek boyut)
        if let allocated = values.totalFileAllocatedSize, allocated > 0 {
            return Int64(allocated)
        }
        if let allocated = values.fileAllocatedSize, allocated > 0 {
            return Int64(allocated)
        }
        // Fallback: logical size
        if let size = values.totalFileSize {
            return Int64(size)
        }
        if let size = values.fileSize {
            return Int64(size)
        }
        return 0
    }

    // MARK: - Helpers

    private func isInsideHomeLibrary(_ url: URL) -> Bool {
        url.standardizedFileURL.path.hasPrefix(homeLibrary.path)
    }

    private func isInsideSystemLibrary(_ url: URL) -> Bool {
        let path = url.standardizedFileURL.path
        // Sadece /Library/ altini kabul et, /System/Library/ vs. degil
        return path.hasPrefix("/Library/") && !path.hasPrefix("/Library/Apple")
    }

    private func isSymlink(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) ?? false
    }

    // MARK: - Info.plist Helpers

    private func getExecutableName(from appURL: URL) -> String? {
        let plistURL = appURL.appendingPathComponent("Contents/Info.plist")
        guard let plistData = try? Data(contentsOf: plistURL),
              let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else {
            return nil
        }
        return plist["CFBundleExecutable"] as? String
    }

    private func getDeveloperName(from appURL: URL) -> String? {
        let plistURL = appURL.appendingPathComponent("Contents/Info.plist")
        guard let plistData = try? Data(contentsOf: plistURL),
              let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else {
            return nil
        }
        
        if let copyright = plist["NSHumanReadableCopyright"] as? String {
            return extractCompanyName(from: copyright)
        }
        return nil
    }

    private func extractCompanyName(from copyright: String) -> String? {
        let patterns = [
            "©\\s*\\d{4}\\s+([A-Za-z][A-Za-z0-9\\s]+?)(?:\\.|,|All|Inc|LLC|Ltd|Corp|$)",
            "Copyright\\s*(?:©)?\\s*\\d{4}\\s+([A-Za-z][A-Za-z0-9\\s]+?)(?:\\.|,|All|Inc|LLC|Ltd|Corp|$)",
            "by\\s+([A-Za-z][A-Za-z0-9\\s]+?)(?:\\.|,|$)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: copyright, range: NSRange(copyright.startIndex..., in: copyright)),
               let range = Range(match.range(at: 1), in: copyright) {
                let name = String(copyright[range])
                    .trimmingCharacters(in: .whitespaces)
                    .components(separatedBy: .whitespaces)
                    .first ?? ""
                if !name.isEmpty && name.count > 2 {
                    return name
                }
            }
        }
        return nil
    }

    // MARK: - Embedded Helper Apps

    private func findEmbeddedHelperApps(appURL: URL, baseTerms: SearchTerms) -> [Candidate] {
        var results: [Candidate] = []
        
        let helperPaths = [
            "Contents/Library/LoginItems",
            "Contents/Library/LaunchServices",
            "Contents/Helpers",
            "Contents/XPCServices"
        ]
        
        for helperPath in helperPaths {
            let helperDir = appURL.appendingPathComponent(helperPath)
            guard fileManager.fileExists(atPath: helperDir.path) else { continue }
            
            guard let contents = try? fileManager.contentsOfDirectory(
                at: helperDir,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else { continue }
            
            for itemURL in contents {
                let ext = itemURL.pathExtension.lowercased()
                guard ext == "app" || ext == "xpc" else { continue }
                
                if let helperBundle = Bundle(url: itemURL),
                   let helperBundleId = helperBundle.bundleIdentifier {
                    let helperTerms = buildSearchTerms(
                        bundleId: helperBundleId,
                        appName: itemURL.deletingPathExtension().lastPathComponent,
                        appURL: itemURL
                    )
                    let launchResults = searchLaunchItemsForHelper(searchTerms: helperTerms)
                    results.append(contentsOf: launchResults)
                }
            }
        }
        
        return results
    }

    private func searchLaunchItemsForHelper(searchTerms: SearchTerms) -> [Candidate] {
        var results: [Candidate] = []
        
        var launchDirs: [(URL, UninstallItemKind)] = [
            (homeLibrary.appendingPathComponent("LaunchAgents"), .launchAgents),
        ]
        
        if includeSystemLocations {
            launchDirs.append((URL(fileURLWithPath: "/Library/LaunchAgents"), .systemLaunchAgents))
            launchDirs.append((URL(fileURLWithPath: "/Library/LaunchDaemons"), .systemLaunchDaemons))
        }
        
        for (dirURL, kind) in launchDirs {
            guard fileManager.fileExists(atPath: dirURL.path) else { continue }
            
            guard let contents = try? fileManager.contentsOfDirectory(
                at: dirURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else { continue }
            
            for plistURL in contents where plistURL.pathExtension == "plist" {
                let name = plistURL.deletingPathExtension().lastPathComponent
                if searchTerms.matchesStrict(name) {
                    results.append(Candidate(
                        url: plistURL,
                        kind: kind,
                        note: "Helper: \(dirURL.lastPathComponent)"
                    ))
                }
            }
        }
        
        return results
    }

    // MARK: - Installer Receipts

// MARK: - Installer Receipts

    private func searchInstallerReceipts(searchTerms: SearchTerms, bundleId: String?) -> [Candidate] {
        guard includeSystemLocations else { return [] }
        
        var results: [Candidate] = []
        let receiptsDir = URL(fileURLWithPath: "/private/var/db/receipts")
        
        guard fileManager.fileExists(atPath: receiptsDir.path) else { return results }
        
        guard let contents = try? fileManager.contentsOfDirectory(
            at: receiptsDir,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return results }
        
        for url in contents {
            let ext = url.pathExtension.lowercased()
            guard ext == "bom" || ext == "plist" else { continue }
            
            let receiptBase = url.deletingPathExtension().lastPathComponent
            var matches = false
            
            if let bundleId = bundleId {
                let bundleLower = bundleId.lowercased()
                let baseLower = receiptBase.lowercased()
                if baseLower == bundleLower || baseLower.hasPrefix(bundleLower) {
                    matches = true
                }
            }
            
            if !matches {
                matches = searchTerms.matchesStrict(receiptBase)
            }
            
            if matches {
                results.append(Candidate(
                    url: url,
                    kind: .other,
                    note: "Installer Receipt"
                ))
            }
        }
        
        return results
    }
}

```

---

## FILE: CleanerApp/UninstallerView.swift

```swift
import SwiftUI
import UniformTypeIdentifiers

struct UninstallerView: View {
    @StateObject private var viewModel = UninstallerViewModel()
    @State private var isTargeted: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    dropArea
                    errorBanner
                    appInfo
                    itemsSection
                    resultSummary
                    undoHistorySection
                }
                .padding()
                .padding(.bottom, 96) // allow space for the action bar
            }

            bottomBar
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Uygulama Kaldır")
                    .font(.title)
                    .bold()
                Spacer()
                Button("Sıfırla") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.appURL == nil && viewModel.items.isEmpty && viewModel.resultSummary == nil && viewModel.errorMessage == nil)
            }
            
            Text("Bir .app sürükleyip bırak, Library altındaki kalan dosyaları bulup Çöp Kutusu'na taşı.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Drop area

    private var dropArea: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(isTargeted ? Color.accentColor : Color.gray.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [8]))
            .frame(height: 180)
            .overlay(
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.down.on.square")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)
                    Text(".app dosyasını buraya bırak")
                        .font(.title3)
                        .fontWeight(.medium)
                    Text("Sadece uygulama paketleri kabul edilir.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            )
            .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted) { providers in
                viewModel.handleDrop(providers: providers)
            }
    }

    // MARK: - Info note & System Scan Toggle

    private var infoNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Guvenlik: Sadece sectigin uygulama paketi ve ~/Library altindaki yollar listelenir.")
                .font(.caption)
                .foregroundColor(.secondary)

            Toggle(isOn: $viewModel.includeSystemLocations) {
                HStack(spacing: 4) {
                    Image(systemName: "gearshape.2")
                        .foregroundColor(.secondary)
                    Text("Sistem dosyalarini da tara")
                        .font(.caption)
                }
            }
            .toggleStyle(.checkbox)
            .onChange(of: viewModel.includeSystemLocations) { _, newValue in
                // Toggle degistiginde uygulama yukluyse yeniden tara
                if viewModel.appURL != nil {
                    if let url = viewModel.appURL {
                        viewModel.loadApp(at: url)
                    }
                }
            }

            if viewModel.includeSystemLocations {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("/Library/ altindaki sistem dosyalari da taranacak (admin yetkisi gerektirebilir)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Error

    private var errorBanner: some View {
        Group {
            if let message = viewModel.errorMessage, !message.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(10)
                .background(Color.yellow.opacity(0.15))
                .cornerRadius(8)
            }
        }
    }

    // MARK: - App info

    private var appInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Seçilen Uygulama")
                .font(.headline)

            if let appURL = viewModel.appURL {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.appName.isEmpty ? appURL.deletingPathExtension().lastPathComponent : viewModel.appName)
                        .font(.title3)
                        .bold()
                    Text("Bundle ID: \(viewModel.bundleIdentifier.isEmpty ? "-" : viewModel.bundleIdentifier)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(appURL.path)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding()
                .background(Color.gray.opacity(0.06))
                .cornerRadius(10)
            } else {
                Text("Henüz bir uygulama seçilmedi.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 6)
            }
        }
    }

    // MARK: - Items

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Öğeler")
                    .font(.headline)
                if viewModel.isScanning {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            if viewModel.items.isEmpty {
                Group {
                    if viewModel.isScanning {
                        Text("Tarama yapılıyor...")
                    } else if viewModel.appURL != nil {
                        Text("Liste boş. Uygulama paketi ve kalıntılar bulunamadı.")
                    } else {
                        Text(".app bırak ve öğeleri listele.")
                    }
                }
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
            } else {
                List {
                    ForEach($viewModel.items) { $item in
                        HStack(alignment: .center, spacing: 12) {
                            // İkon eklendi
                            Image(systemName: iconName(for: item.kind))
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                // Satır 1: İsim + Tür badge
                                HStack(spacing: 8) {
                                    Text(item.displayName)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .lineLimit(1)
                                    
                                    Text(item.kind.rawValue)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.secondary.opacity(0.15))
                                        .cornerRadius(4)
                                }
                                
                                // Satır 2: Path (kısaltılmış)
                                Text(item.url.path.replacingOccurrences(of: NSHomeDirectory(), with: "~"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }

                            Spacer()

                            // Boyut ve checkbox yan yana
                            HStack(spacing: 12) {
                                Text(sizeText(for: item))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 70, alignment: .trailing)
                                
                                Toggle("", isOn: $item.isSelected)
                                    .labelsHidden()
                                    .toggleStyle(.checkbox)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .frame(minHeight: 280, maxHeight: 500)
                .listStyle(.inset(alternatesRowBackgrounds: true))
            }
        }
    }

    // MARK: - Action

    private var bottomBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 16) {
                    // Seçili öğe sayısı ve boyutu
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Seçili: \(viewModel.selectedCount) öğe")
                            .font(.subheadline)
                    }
                    
                    // Seçili toplam boyut
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text(viewModel.selectedTotalSize)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    // Toplam boyut (tüm öğeler)
                    if viewModel.selectedCount != viewModel.items.count {
                        Text("/ \(viewModel.totalSize)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("Tarama kapsamı: uygulama paketi ve ~/Library altındaki güvenli yollar.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button {
                viewModel.moveSelectedToTrash()
            } label: {
                HStack(spacing: 6) {
                    if viewModel.isProcessing {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "trash")
                    }
                    Text("Çöp Kutusuna Taşı")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isProcessing || viewModel.selectedCount == 0)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    // MARK: - Result

    private var resultSummary: some View {
        Group {
            if let summary = viewModel.resultSummary {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Sonuç Özeti")
                        .font(.headline)
                    HStack(spacing: 12) {
                        Label("Taşındı: \(summary.moved)", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Label("Atlandı: \(summary.skipped)", systemImage: "minus.circle")
                            .foregroundColor(.orange)
                        Label("Hata: \(summary.failed)", systemImage: "xmark.octagon.fill")
                            .foregroundColor(.red)
                    }
                    ForEach(summary.messages, id: \.self) { message in
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .truncationMode(.middle)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.06))
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Undo History

    private var undoHistorySection: some View {
        Group {
            if !viewModel.uninstallHistory.isEmpty {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.green)
                        Text("Son Kaldırılanlar")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        if viewModel.uninstallHistory.count > 1 {
                            Text("\(viewModel.uninstallHistory.count) uygulama")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Button("Geçmişi Temizle") {
                            viewModel.clearUndoHistory()
                        }
                        .font(.caption)
                        .buttonStyle(.borderless)
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(viewModel.uninstallHistory) { transaction in
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(transaction.appName.isEmpty ? "Bilinmeyen" : transaction.appName)
                                            .font(.subheadline)
                                        HStack(spacing: 8) {
                                            Text("\(transaction.itemCount) öğe")
                                            Text("•")
                                            Text(transaction.formattedSize)
                                            Text("•")
                                            Text(transaction.date, style: .relative)
                                        }
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        viewModel.undoUninstall(transaction)
                                    } label: {
                                        HStack(spacing: 4) {
                                            if viewModel.isUndoing {
                                                ProgressView()
                                                    .controlSize(.small)
                                            } else {
                                                Image(systemName: "arrow.uturn.backward")
                                            }
                                            Text("Geri Al")
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .disabled(viewModel.isUndoing)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                            }
                        }
                    }
                    .frame(maxHeight: 120)
                }
                .background(Color.green.opacity(0.05))
                .cornerRadius(10)
            }
        }
    }

    // MARK: - Helpers

    private func iconName(for kind: UninstallItemKind) -> String {
        switch kind {
        case .appBundle:
            return "app.badge.fill"
        case .applicationSupport:
            return "folder.fill"
        case .caches:
            return "archivebox.fill"
        case .preferences:
            return "gearshape.fill"
        case .preferencesByHost:
            return "gearshape.2.fill"
        case .logs:
            return "doc.text.fill"
        case .savedState:
            return "clock.fill"
        case .containers:
            return "shippingbox.fill"
        case .groupContainers:
            return "shippingbox.and.arrow.backward.fill"
        case .launchAgents:
            return "bolt.fill"
        case .httpStorages:
            return "network"
        case .webKit:
            return "globe"
        case .cookies:
            return "cpu.fill"
        case .crashReports:
            return "exclamationmark.triangle.fill"
        case .applicationScripts:
            return "applescript.fill"
        case .internetPlugins:
            return "puzzlepiece.extension.fill"
        case .preferencePanes:
            return "slider.horizontal.3"
        case .quickLook:
            return "eye.fill"
        case .screenSavers:
            return "rectangle.on.rectangle"
        case .services:
            return "gear.badge.checkmark"
        case .spotlight:
            return "magnifyingglass.circle.fill"
        case .inputMethods:
            return "keyboard.fill"
        case .frameworks:
            return "cube.box.fill"
        case .colorPickers:
            return "paintpalette.fill"
        case .addressBookPlugins:
            return "person.crop.circle.fill"
        case .mailBundles:
            return "envelope.fill"
        case .developer:
            return "hammer.fill"
        case .recentDocuments:
            return "clock.arrow.circlepath"
        case .systemAppSupport:
            return "folder.badge.gearshape"
        case .systemLaunchAgents:
            return "bolt.badge.a"
        case .systemLaunchDaemons:
            return "bolt.badge.checkmark"
        case .privilegedHelpers:
            return "shield.lefthalf.filled"
        case .systemPreferences:
            return "system.settings"
        case .systemFrameworks:
            return "cube.box.badge.gearshape"
        case .other:
            return "questionmark.folder.fill"
        }
    }

    private func sizeText(for item: UninstallItem) -> String {
        guard let size = item.sizeBytes else { return "-" }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

```

---

## FILE: CleanerApp/UninstallerViewModel.swift

```swift
import Foundation
import AppKit
import UniformTypeIdentifiers
import Combine

struct UninstallResultSummary {
    let moved: Int
    let skipped: Int
    let failed: Int
    let messages: [String]
}

struct UninstallTransactionItem: Identifiable {
    let id = UUID()
    let originalURL: URL
    let trashedURL: URL
    let sizeBytes: Int64?
    let displayName: String
}

struct UninstallTransaction: Identifiable {
    let id = UUID()
    let date: Date
    let appName: String
    let items: [UninstallTransactionItem]
    let totalBytes: Int64

    var itemCount: Int { items.count }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
    }
}

final class UninstallerViewModel: ObservableObject {
    @Published var appURL: URL?
    @Published var appName: String = ""
    @Published var bundleIdentifier: String = ""
    @Published var errorMessage: String?
    @Published var items: [UninstallItem] = []
    @Published var isScanning: Bool = false
    @Published var isProcessing: Bool = false
    @Published var resultSummary: UninstallResultSummary?
    // MARK: - System Locations
    @Published var includeSystemLocations: Bool = false
    // MARK: - Undo Support
    @Published var uninstallHistory: [UninstallTransaction] = []  // Son 10 islem
    @Published var isUndoing: Bool = false
    @Published var undoError: String? = nil

    private let maxHistoryCount = 10

    // MARK: - Computed Properties
    
    /// Seçili öğelerin toplam sayısı
    var selectedCount: Int {
        items.filter { $0.isSelected }.count
    }
    
    /// Seçili öğelerin toplam boyutu (bytes)
    var selectedTotalBytes: Int64 {
        items.filter { $0.isSelected }.reduce(0) { $0 + ($1.sizeBytes ?? 0) }
    }
    
    /// Seçili öğelerin toplam boyutu (formatlanmış string)
    var selectedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: selectedTotalBytes, countStyle: .file)
    }
    
    /// Tüm öğelerin toplam boyutu (bytes)
    var totalBytes: Int64 {
        items.reduce(0) { $0 + ($1.sizeBytes ?? 0) }
    }
    
    /// Tüm öğelerin toplam boyutu (formatlanmış string)
    var totalSize: String {
        ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
    }
    
    /// Geri alma yapılabilir mi?
    var canUndo: Bool {
        !uninstallHistory.isEmpty && !isUndoing && !isProcessing
    }
    
    /// Tüm geçmişi temizle
    func clearUndoHistory() {
        uninstallHistory.removeAll()
    }

    private let manager = UninstallerManager()
    private let safeDeleteService = SafeDeleteService()
    private let logManager = LogManager.shared

    // MARK: - Reset

    func reset() {
        appURL = nil
        appName = ""
        bundleIdentifier = ""
        items = []
        isScanning = false
        isProcessing = false
        resultSummary = nil
        errorMessage = nil
        // uninstallHistory'yi koruyoruz; diğer uygulamalar için geri alma mümkün kalsın.
    }

    // MARK: - Drop handling

    func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) }) else {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "Geçerli bir uygulama bulunamadı."
            }
            return false
        }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { [weak self] (item, error) in
            if let error = error {
                DispatchQueue.main.async { self?.errorMessage = error.localizedDescription }
                return
            }

            let url: URL?
            if let data = item as? Data {
                url = URL(dataRepresentation: data, relativeTo: nil)
            } else if let nsUrl = item as? NSURL {
                url = nsUrl as URL
            } else {
                url = nil
            }

            guard let appURL = url else {
                DispatchQueue.main.async { self?.errorMessage = "Geçersiz dosya." }
                return
            }

            DispatchQueue.main.async {
                self?.reset()
                self?.loadApp(at: appURL)
            }
        }

        return true
    }

    func loadApp(at url: URL) {
        guard let validated = validate(appURL: url) else { return }

        appURL = url
        appName = validated.name
        bundleIdentifier = validated.bundleId ?? ""
        errorMessage = nil
        resultSummary = nil

        scanItems(bundleId: validated.bundleId, appName: validated.name, appURL: url)
    }

    // MARK: - Actions

    func moveSelectedToTrash() {
        guard !isProcessing else { return }
        let selected = items.filter { $0.isSelected }
        guard !selected.isEmpty else {
            resultSummary = UninstallResultSummary(moved: 0, skipped: 0, failed: 0, messages: ["Secilmis oge yok."])
            return
        }

        isProcessing = true
        resultSummary = nil
        errorMessage = nil

        let urls = selected.map { $0.url }
        let allowedExtras = appURL.map { [$0] } ?? []
        let selectedLookup: [String: UninstallItem] = Dictionary(uniqueKeysWithValues: selected.map { ($0.url.standardizedFileURL.path, $0) })

        // Use smartMoveToTrash which handles AppleScript admin elevation automatically
        safeDeleteService.smartMoveToTrash(urls: urls, allowedOutsideHome: allowedExtras) { [weak self] result in
            guard let self = self else { return }

            let movedSet = Set(result.moved.map { $0.original })
            self.items.removeAll { movedSet.contains($0.url) }

            var messages: [String] = []

            // Handle user cancellation specially
            if result.userCancelled {
                messages.append("Kullanici admin yetkisi istemini iptal etti")
            }

            let errorMessages = result.failed.map { "\($0.url.lastPathComponent): \($0.error.localizedDescription) (kod \($0.error.code))" }
            let skipMessages = result.skipped.map { "\($0.url.lastPathComponent): \($0.reason)" }
            messages.append(contentsOf: errorMessages)
            messages.append(contentsOf: skipMessages)

            if messages.isEmpty {
                messages = result.notes
            }

            // Track which files used admin privileges
            let adminCount = result.moved.filter { $0.usedAdminPrivileges }.count
            if adminCount > 0 {
                self.logManager.log("Uninstaller: \(adminCount) dosya admin yetkisiyle silindi", category: .cleanup, level: .info)
            }

            let transactionItems: [UninstallTransactionItem] = result.moved.compactMap { moved in
                guard let trashed = moved.trashedURL else { return nil }
                let key = moved.original.standardizedFileURL.path
                let info = selectedLookup[key]
                return UninstallTransactionItem(
                    originalURL: moved.original,
                    trashedURL: trashed,
                    sizeBytes: info?.sizeBytes,
                    displayName: info?.displayName ?? moved.original.lastPathComponent
                )
            }
            let totalBytes = transactionItems.reduce(into: Int64(0)) { partial, item in
                partial += item.sizeBytes ?? 0
            }

            let summary = UninstallResultSummary(
                moved: result.moved.count,
                skipped: result.skipped.count,
                failed: result.failed.count,
                messages: Array(messages.prefix(5))
            )
            self.resultSummary = summary
            self.isProcessing = false

            // Show special error if user cancelled
            if result.userCancelled && result.moved.isEmpty {
                self.errorMessage = "Islem iptal edildi. Korumali dosyalar icin admin yetkisi gerekli."
            }

            let appLabel = self.appName.isEmpty ? "Bilinmeyen" : self.appName
            self.logManager.log("Uninstaller \(appLabel): \(summary.moved) tasindi / \(summary.skipped) atlandi / \(summary.failed) hata", category: .cleanup, level: .info)

            if !transactionItems.isEmpty {
                let transaction = UninstallTransaction(
                    date: Date(),
                    appName: appLabel,
                    items: transactionItems,
                    totalBytes: totalBytes
                )
                self.uninstallHistory.insert(transaction, at: 0)
                if self.uninstallHistory.count > self.maxHistoryCount {
                    self.uninstallHistory = Array(self.uninstallHistory.prefix(self.maxHistoryCount))
                }
            }

            if movedSet.contains(where: { $0 == self.appURL }) {
                self.reset()
            }
        }
    }

    /// Belirli bir kaldırma işlemini geri alır
    func undoUninstall(_ transaction: UninstallTransaction) {
        guard !isUndoing else { return }
        isUndoing = true
        undoError = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let fm = FileManager.default
            var restoredCount = 0
            var errors: [Error] = []

            for item in transaction.items {
                let original = item.originalURL.standardizedFileURL
                let trashed = item.trashedURL.standardizedFileURL

                if self.isSymlink(original) || self.isSymlink(trashed) {
                    continue
                }

                guard fm.fileExists(atPath: trashed.path) else { continue }

                let target = self.safeRestoreTarget(for: original, fileManager: fm)

                do {
                    try fm.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
                    try fm.moveItem(at: trashed, to: target)
                    restoredCount += 1
                } catch {
                    errors.append(error)
                }
            }

            DispatchQueue.main.async {
                self.isUndoing = false
                if restoredCount > 0 {
                    self.uninstallHistory.removeAll { $0.id == transaction.id }
                    self.resultSummary = nil
                    self.logManager.log("Uninstaller undo: \(restoredCount)/\(transaction.items.count) öğe geri alındı (\(transaction.appName))", category: .cleanup, level: .info)
                } else if let first = errors.first {
                    self.undoError = first.localizedDescription
                    self.logManager.log("Uninstaller undo hata: \(first.localizedDescription)", category: .error, level: .error)
                }
            }
        }
    }

    // MARK: - Private

    private func validate(appURL url: URL) -> (name: String, bundleId: String?)? {
        guard url.isFileURL else {
            errorMessage = "Sadece .app dosyalarını bırakabilirsin."
            return nil
        }

        guard url.pathExtension.lowercased() == "app" else {
            errorMessage = "Sadece .app dosyalarını bırakabilirsin."
            return nil
        }

        guard FileManager.default.isReadableFile(atPath: url.path) else {
            errorMessage = "Uygulama okunamıyor."
            return nil
        }

        guard let bundle = Bundle(url: url) else {
            errorMessage = "Uygulama bilgisi alınamadı."
            return nil
        }

        let name = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? url.deletingPathExtension().lastPathComponent

        errorMessage = nil
        return (name: name, bundleId: bundle.bundleIdentifier)
    }

    private func scanItems(bundleId: String?, appName: String, appURL: URL) {
        isScanning = true
        items = []

        // Sistem konumlari tarama ayarini manager'a aktar
        manager.includeSystemLocations = includeSystemLocations

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let found = self.manager.buildItems(appURL: appURL, bundleId: bundleId, appName: appName)
            DispatchQueue.main.async {
                self.items = found
                self.isScanning = false
            }
        }
    }

    private func isSymlink(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) ?? false
    }

    private func safeRestoreTarget(for original: URL, fileManager: FileManager) -> URL {
        if !fileManager.fileExists(atPath: original.path) {
            return original
        }
        let base = original.deletingPathExtension()
        let ext = original.pathExtension.isEmpty ? nil : original.pathExtension
        var counter = 1
        while true {
            let candidateName = "\(base.lastPathComponent) (Restored \(counter))"
            var candidate = base.deletingLastPathComponent().appendingPathComponent(candidateName)
            if let ext { candidate.appendPathExtension(ext) }
            if !fileManager.fileExists(atPath: candidate.path) {
                return candidate
            }
            counter += 1
        }
    }
}

```

---

## FILE: CleanerApp/View+Glass.swift

```swift
import SwiftUI

// MARK: - Adaptive Glass Effect for Views
extension View {
    /// Applies Liquid Glass on macOS 26+, falls back to material background on older versions.
    @ViewBuilder
    func adaptiveGlassEffect<S: Shape>(
        _ material: Material = .ultraThinMaterial,
        in shape: S
    ) -> some View {
        if #available(macOS 26.0, *) {
            self.glassEffect(.regular, in: shape)
        } else {
            self.background(material, in: shape)
        }
    }
}

// MARK: - Adaptive Glass Button Styles
extension View {
    /// Applies glass button style on macOS 26+, falls back to bordered styles on older versions.
    @ViewBuilder
    func adaptiveGlassButtonStyle(prominent: Bool = false) -> some View {
        if #available(macOS 26.0, *) {
            if prominent {
                self.buttonStyle(.glassProminent)
            } else {
                self.buttonStyle(.glass)
            }
        } else {
            if prominent {
                self.buttonStyle(.borderedProminent)
            } else {
                self.buttonStyle(.bordered)
            }
        }
    }
}

```

---

## FILE: CleanerApp.xcodeproj/project.pbxproj

```text
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 77;
	objects = {

/* Begin PBXFileReference section */
		05F54BF22EE7A7FF0098CB86 /* DustBuster.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = DustBuster.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXFileSystemSynchronizedBuildFileExceptionSet section */
		05A26F8D2EEE0D8E00B76FC3 /* Exceptions for "CleanerApp" folder in "DustBuster" target */ = {
			isa = PBXFileSystemSynchronizedBuildFileExceptionSet;
			membershipExceptions = (
				Info.plist,
			);
			target = 05F54BF12EE7A7FF0098CB86 /* DustBuster */;
		};
/* End PBXFileSystemSynchronizedBuildFileExceptionSet section */

/* Begin PBXFileSystemSynchronizedRootGroup section */
		05F54BF42EE7A7FF0098CB86 /* CleanerApp */ = {
			isa = PBXFileSystemSynchronizedRootGroup;
			exceptions = (
				05A26F8D2EEE0D8E00B76FC3 /* Exceptions for "CleanerApp" folder in "DustBuster" target */,
			);
			path = CleanerApp;
			sourceTree = "<group>";
		};
/* End PBXFileSystemSynchronizedRootGroup section */

/* Begin PBXFrameworksBuildPhase section */
		05F54BEF2EE7A7FF0098CB86 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		05F54BE92EE7A7FF0098CB86 = {
			isa = PBXGroup;
			children = (
				05F54BF42EE7A7FF0098CB86 /* CleanerApp */,
				05F54BF32EE7A7FF0098CB86 /* Products */,
			);
			sourceTree = "<group>";
		};
		05F54BF32EE7A7FF0098CB86 /* Products */ = {
			isa = PBXGroup;
			children = (
				05F54BF22EE7A7FF0098CB86 /* DustBuster.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		05F54BF12EE7A7FF0098CB86 /* DustBuster */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 05F54BFD2EE7A8000098CB86 /* Build configuration list for PBXNativeTarget "DustBuster" */;
			buildPhases = (
				05F54BEE2EE7A7FF0098CB86 /* Sources */,
				05F54BEF2EE7A7FF0098CB86 /* Frameworks */,
				05F54BF02EE7A7FF0098CB86 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			fileSystemSynchronizedGroups = (
				05F54BF42EE7A7FF0098CB86 /* CleanerApp */,
			);
			name = DustBuster;
			packageProductDependencies = (
			);
			productName = CleanerApp;
			productReference = 05F54BF22EE7A7FF0098CB86 /* DustBuster.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		05F54BEA2EE7A7FF0098CB86 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 2610;
				LastUpgradeCheck = 2620;
				TargetAttributes = {
					05F54BF12EE7A7FF0098CB86 = {
						CreatedOnToolsVersion = 26.1.1;
					};
				};
			};
			buildConfigurationList = 05F54BED2EE7A7FF0098CB86 /* Build configuration list for PBXProject "CleanerApp" */;
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = 05F54BE92EE7A7FF0098CB86;
			minimizedProjectReferenceProxies = 1;
			preferredProjectObjectVersion = 77;
			productRefGroup = 05F54BF32EE7A7FF0098CB86 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				05F54BF12EE7A7FF0098CB86 /* DustBuster */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		05F54BF02EE7A7FF0098CB86 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		05F54BEE2EE7A7FF0098CB86 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		05F54BFB2EE7A8000098CB86 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEAD_CODE_STRIPPING = YES;
				DEBUG_INFORMATION_FORMAT = dwarf;
				DEVELOPMENT_TEAM = WJM6K52G7T;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = macosx;
				STRING_CATALOG_GENERATE_SYMBOLS = YES;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		05F54BFC2EE7A8000098CB86 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEAD_CODE_STRIPPING = YES;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				DEVELOPMENT_TEAM = WJM6K52G7T;
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = macosx;
				STRING_CATALOG_GENERATE_SYMBOLS = YES;
				SWIFT_COMPILATION_MODE = wholemodule;
			};
			name = Release;
		};
		05F54BFE2EE7A8000098CB86 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEAD_CODE_STRIPPING = YES;
				DEVELOPMENT_TEAM = WJM6K52G7T;
				ENABLE_APP_SANDBOX = NO;
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				INFOPLIST_FILE = CleanerApp/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = muratonurcu.CleanerApp;
				PRODUCT_NAME = "$(TARGET_NAME)";
				REGISTER_APP_GROUPS = YES;
				STRING_CATALOG_GENERATE_SYMBOLS = YES;
				SWIFT_APPROACHABLE_CONCURRENCY = YES;
				SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		05F54BFF2EE7A8000098CB86 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEAD_CODE_STRIPPING = YES;
				DEVELOPMENT_TEAM = WJM6K52G7T;
				ENABLE_APP_SANDBOX = NO;
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				INFOPLIST_FILE = CleanerApp/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = muratonurcu.CleanerApp;
				PRODUCT_NAME = "$(TARGET_NAME)";
				REGISTER_APP_GROUPS = YES;
				STRING_CATALOG_GENERATE_SYMBOLS = YES;
				SWIFT_APPROACHABLE_CONCURRENCY = YES;
				SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		05F54BED2EE7A7FF0098CB86 /* Build configuration list for PBXProject "CleanerApp" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				05F54BFB2EE7A8000098CB86 /* Debug */,
				05F54BFC2EE7A8000098CB86 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		05F54BFD2EE7A8000098CB86 /* Build configuration list for PBXNativeTarget "DustBuster" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				05F54BFE2EE7A8000098CB86 /* Debug */,
				05F54BFF2EE7A8000098CB86 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = 05F54BEA2EE7A7FF0098CB86 /* Project object */;
}

```

---

## FILE: CleanerApp.xcodeproj/project.xcworkspace/contents.xcworkspacedata

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>

```

---

## FILE: CleanerApp.xcodeproj/xcuserdata/muratonurcu.xcuserdatad/xcschemes/xcschememanagement.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>SchemeUserState</key>
	<dict>
		<key>DustBuster.xcscheme_^#shared#^_</key>
		<dict>
			<key>orderHint</key>
			<integer>0</integer>
		</dict>
	</dict>
</dict>
</plist>

```

---

## FILE: FULL_PROJECT_XRAY.md

```markdown

# FULL_PROJECT_XRAY.md

## 1. File Inventory & Logic Map

| File Name | Actual Role | Key Functions | Hidden Features / Notes |
| :--- | :--- | :--- | :--- |
| **AppPermissionViewModel.swift** | Manages and monitors the app's Full Disk Access permission state. | `refreshFullDiskAccessStatus()` | Uses Combine to reactively update views and listens for app activation to re-check permissions. |
| **CleanerAppApp.swift** | The main entry point of the application. | `CleanAppApp` (main App struct) | Injects the `AppPermissionViewModel` into the environment. Sets a hidden title bar style. |
| **CleanerManager.swift** | Core logic for scanning and deleting junk files. | `scan()`, `clean()`, `isSafeToDelete()` | Contains extensive safety checks, including a `forbiddenPaths` list and `sensitiveKeywords` to prevent accidental data loss. Dynamically detects Chromium-based browser caches. |
| **CleanerOptionsView.swift** | A sheet view to display scanned files and allow the user to select which ones to delete. | `sortedItems` (computed property), `toggleSortOrder()` | Manages sorting and selection of files to be cleaned. |
| **ContentView.swift** | The root view of the application. | `ContentView` | Sets up the main `NavigationSplitView`. |
| **DashboardView.swift** | The main dashboard of the application. | `DashboardView`, `UsageCard`, `UsageRingView` | Displays system stats (RAM, Disk, CPU) and provides an interface for initiating a system scan. |
| **DashboardViewModel.swift** | The ViewModel for the `DashboardView`. | `scanSystem()`, `cleanSelectedItems()` | Acts as a central coordinator for the `SystemMonitor`, `CleanerManager`, and `PermissionManager`. Marked with `@MainActor`. |
| **FileItem.swift** | Data model for a file or folder identified for cleaning. | `displayName` (computed property) | Contains a lot of logic to generate user-friendly names for cache files, which would be better placed in a separate service. |
| **FullDiskAccessLockedView.swift** | A view displayed when Full Disk Access is not granted. | `FullDiskAccessLockedView` | Provides a button to directly open the system settings for Full Disk Access. |
| **LargeFileItem.swift** | A simplified data model for a large file. | (none) | A straightforward data model. |
| **LargeFileManager.swift** | Scans for large files in user-specified directories. | `scan()` | Scans are performed on a background thread. |
| **LargeFilesView.swift** | The UI for the "Large Files" feature. | `LargeFilesView`, `FileRowView` | Displays a list of large files and allows the user to select them for deletion. |
| **LargeFilesViewModel.swift** | The ViewModel for the `LargeFilesView`. | `scheduleScan()`, `deleteSelected()` | Manages the state and logic for the large files feature. |
| **LogManager.swift** | A centralized, privacy-focused logging solution. | `log()`, `exportLogs()`, `sanitize()` | Uses `OSLog` and automatically redacts PII from log messages. |
| **MainDetailRouter.swift** | A router for the main detail view. | `MainDetailRouter` | Uses a `switch` statement to display the correct view based on the sidebar selection. Wraps views in a `PermissionGate`. |
| **MaterialCard.swift** | A reusable card view component. | `MaterialCard`, `MaterialCardModifier` | Provides a consistent "glassmorphism" style for cards. |
| **PermissionGate.swift** | A view that acts as a gatekeeper for content that requires Full Disk Access. | `PermissionGate` | A reusable and elegant way to handle permissions. |
| **PermissionManager.swift** | A singleton that manages Full Disk Access permission. | `checkFullDiskAccess()`, `requestFullDiskAccess()` | Uses a "smart check" by trying to access protected files. |
| **ProcessItem.swift** | Data model for a running process. | (none) | A straightforward data model. |
| **ProcessListView.swift** | A view that lists running third-party applications. | `ProcessListView` | Allows the user to quit or force-quit applications. |
| **ProcessManager.swift** | Manages running applications. | `refresh()`, `terminate()` | Filters out system processes and has a list of protected bundle IDs. |
| **SettingsView.swift** | The settings screen of the application. | `SettingsView` | Displays app info and provides a way to export logs. |
| **SidebarItem.swift** | An enum representing the items in the sidebar. | (none) | `Hashable` for use with SwiftUI navigation. |
| **SidebarView.swift** | The sidebar of the application. | `SidebarView` | A standard SwiftUI sidebar implementation. |
| **SystemMonitor.swift** | Monitors system resource usage (RAM, Disk, CPU). | `startMonitoring()`, `updateMetrics()` | Uses low-level C APIs to get system information. |
| **View+Glass.swift** | View extensions for applying a "glassmorphism" effect. | `adaptiveGlassEffect()`, `adaptiveGlassButtonStyle()` | Uses `@available` to provide modern effects on newer macOS versions while maintaining compatibility with older ones. |

## 2. Feature Verification (True/False)

- **App Uninstaller:** **False**. The code does not contain any logic to find and remove associated app files (containers, caches, etc.) for a full application uninstall. The `CleanerManager` is focused on cleaning temporary files, not uninstalling applications.

- **Glassmorphism/UI:** **True**. The project makes extensive use of a "glassmorphism" effect. The primary implementation is in `View+Glass.swift`:

  ```swift
  // In View+Glass.swift
  @ViewBuilder
  func adaptiveGlassEffect<S: Shape>(
      _ material: Material = .ultraThinMaterial,
      in shape: S
  ) -> some View {
      if #available(macOS 26.0, *) {
          self.glassEffect(.regular, in: shape)
      } else {
          self.background(material, in: shape)
      }
  }
  ```

  This effect is then applied throughout the app using the `.adaptiveGlassEffect()` modifier, for example in `MaterialCard.swift`:

  ```swift
  // In MaterialCard.swift
  struct MaterialCardModifier: ViewModifier {
      func body(content: Content) -> some View {
          content
              .padding()
              .adaptiveGlassEffect(in: .rect(cornerRadius: 16))
      }
  }
  ```

## 3. Code Health Check

- **Modern Concurrency:** The project uses a mix of modern and traditional concurrency patterns.
  - **`async/await`:** The `DashboardViewModel` is marked with `@MainActor`, which is a good use of modern concurrency.
  - **`DispatchQueue`:** The `CleanerManager`, `LargeFileManager`, and `SystemMonitor` all use `DispatchQueue.global()` to perform work on a background thread and then `DispatchQueue.main.async` to update the UI. This is a correct and safe pattern, but some of this code could be updated to use `async/await` with `Task`s.
  - **Combine:** The project makes excellent use of the Combine framework for reactive data flow, especially in the ViewModels.

- **Hardcoded Values:**
  - **Strings:** There are many hardcoded strings, especially in the UI (e.g., "Sistem Durumu", "Disk Erişimi Gerekli"). These should be extracted into a localization file to support multiple languages.
  - **Paths:** The `CleanerManager` has many hardcoded paths and keywords. While this is necessary for its function, it makes the code rigid and hard to maintain. A more flexible rule-based system could be considered for the long term.
  - **Colors:** Colors are generally well-managed (e.g., `.green`, `.orange`), but a centralized color palette or theme file would improve consistency.

- **Spaghetti Code:**
  - **`CleanerManager.swift`:** The `isSafeToDelete()` function is very complex and could be refactored for clarity.
  - **`FileItem.swift`:** The `displayName` computed property has too much logic for a simple data model.
  - **`DashboardViewModel.swift`:** This ViewModel has a lot of responsibilities and could be considered a "God Object".

## 4. Architect's Verdict

### Summary of the Current State

This project is a well-structured and thoughtfully designed macOS utility. The developer has shown a strong understanding of SwiftUI, the MVVM design pattern, and modern Swift features. The focus on safety and user privacy is commendable, especially in the `CleanerManager` and `LogManager`. The code is generally clean, modular, and easy to understand.

### Step-by-Step Recommendation for the Next Development Phase

1.  **Immediate Improvements (Low-Hanging Fruit):**
    *   **Localize UI Strings:** Move all user-facing strings into a `Localizable.strings` file to prepare for localization.
    *   **Refactor `FileItem.displayName`:** Create a new service, e.g., `FileDisplayNameProvider`, to handle the logic of generating display names for files. This will make the `FileItem` a pure data model.
    *   **Refactor `CleanerManager.isSafeToDelete()`:** Break down the complex `isSafeToDelete()` function into smaller, more manageable private functions, each with a single responsibility (e.g., `isPathInForbiddenList()`, `doesPathContainSensitiveKeywords()`).

2.  **Mid-Term Refactoring:**
    *   **Introduce a `CleanerOptionsViewModel`:** Create a dedicated ViewModel for the `CleanerOptionsView`. This will reduce the responsibilities of the `DashboardViewModel` and improve separation of concerns.
    *   **Adopt `async/await` more widely:** Refactor the `CleanerManager`, `LargeFileManager`, and `SystemMonitor` to use `async/await` instead of `DispatchQueue`. This will make the asynchronous code more readable and concise.
    *   **Create a Theme/Style Guide:** Centralize colors, fonts, and other UI constants into a theme file to ensure consistency and make future redesigns easier.

3.  **Long-Term Architectural Goals:**
    *   **Rule Engine for `CleanerManager`:** Replace the hardcoded paths and keywords in `CleanerManager` with a more flexible rule engine. This would allow new cleaning rules to be added easily, perhaps even from a remote configuration file.
    *   **Add Unit and UI Tests:** The project currently lacks tests. Adding a suite of unit tests for the managers and ViewModels, and UI tests for the main user flows, would significantly improve the robustness of the application.
    *   **Dependency Injection:** While the current singleton and manual instantiation approach works, introducing a formal dependency injection container would make the code more testable and maintainable in the long run.

```

---

# 4) Uninstall Akışı İçin Ekstra Çıktılar

Most Relevant Files:
- CleanerApp/UninstallerView.swift — SwiftUI giriş noktası; drop-area, sistem dizin taraması togglesı ve sonuç/geri alma UI'si.
- CleanerApp/UninstallerViewModel.swift — Uygulama yükleme, UninstallerManager.buildItems(...) çağrısı, includeSystemLocations bayrağı, SafeDeleteService.smartMoveToTrash(...) ile silme ve 10 öğeye kadar geri alma geçmişini yönetir.
- CleanerApp/UninstallerManager.swift — Kural/heuristic motoru; bundleId/appName/executable/developer verilerinden SearchTerms üretir, 26 kullanıcı Library kökünü (aşağıda) + ByHost/CrashReports/helper-app/receipt taramalarını, isteğe bağlı 6 sistem /Library kökünü (toggle ile) gezer; symlink ve home dışı path’leri atlar.
- CleanerApp/SafeDeleteService.swift — Silme motoru; Rules(forbiddenPaths + isPathAllowed) ile temizleme güvenliğini sağlar, smartMoveToTrash kullanıcı ev dizini dışına çıkmayı sınırlar ve gerekirse AppleScript/admin yükseltmesi dener, dosya kimliği/symlink/varlık kontrolleri yapar.
- CleanerApp/CleanerManager.swift — Temel forbiddenPaths listesini (/System, /Library, /bin, /sbin, /usr, /Applications) ve hassas anahtar kelime/whitelist kontrollerini tanımlar; SafeDeleteService.Rules kullanımıyla temizlik güvenlik modeli için referans.

Kural Özeti:
- Arama kökleri: 26 kullanıcı Library yolu (Application Support, Caches, Preferences, Logs, Saved Application State, Containers, Group Containers, LaunchAgents, HTTPStorages, WebKit, Cookies, Application Scripts, Caches/com.apple.nsurlsessiond/Downloads, Internet Plug-Ins, PreferencePanes, QuickLook, Screen Savers, Services, Spotlight, Input Methods, Frameworks, ColorPickers, Address Book Plug-Ins, Mail/Bundles, Developer, Recent Documents); includeSystemLocations açılırsa 6 sistem /Library kökü eklenir (Application Support, LaunchAgents, LaunchDaemons, PrivilegedHelperTools, Preferences, Frameworks).
- İsim eşleştirme heuristikleri: SearchTerms exact/prefix/contains (bundleId parçaları, app adı varyantları, executable/developer isimleri) + 13 helperSuffix (.helper/.agent/.updater/.Launcher/.xpc vb.); sistem dizinlerinde strict eşleştirme kullanılır.
- Güvenlik filtreleri: Symlink atlama; kullanıcı aramalarında home/Library sınırı ve derinlik limiti (recursive maxDepth 3), sistem aramalarında maxDepth 2 ve yasak prefixler (/System, /usr, /bin, /sbin, /private); SafeDeleteService smartMoveToTrash home dışı yolları allowedOutsideHome ile sınırlar, kimlik/eşleşme/kullanılabilirlik kontrolü ve Trash’e taşıma öncesi doğrulamalar yapar.
- Kritik 20 kural/konum (ad + not): 1) Application Support (recursive, ana hedef), 2) Caches (recursive), 3) Preferences (ByHost harici düz liste), 4) Logs (recursive), 5) Saved Application State (düz), 6) Containers (düz), 7) Group Containers (recursive), 8) LaunchAgents (düz), 9) HTTPStorages (düz), 10) WebKit (recursive), 11) Cookies (düz), 12) Application Scripts (düz), 13) nsurlsessiond Downloads cache (recursive), 14) Internet Plug-Ins (düz), 15) PreferencePanes (düz), 16) QuickLook (düz), 17) Screen Savers (düz), 18) Services (düz), 19) Spotlight (düz), 20) Input Methods (düz); kalan destekleyiciler: Frameworks/ColorPickers/Address Book Plug-Ins/Mail Bundles/Developer/Recent Documents + opsiyonel sistem /Library eşdeğerleri.
