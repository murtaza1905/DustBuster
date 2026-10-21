#!/usr/bin/env python3
"""
Core/Tests/DustBusterCoreTests/Fixtures altındaki vaka dosyalarını üretir. Vakalar 2026-10-18/20 tarihli gerçek
taramalardan alınmış, negatif kontrollerle (listelenmemesi gereken yollar) genişletilmiştir.

Kullanım: python3 tools/make-fixtures.py
"""
import json
import os

OUT = os.path.join(os.path.dirname(__file__), "..", "Core", "Tests", "DustBusterCoreTests", "Fixtures")


def identity(name, bundle_id, app_path, executable=None, embedded=None, team=None, groups=None,
             icloud=None, sandboxed=False, receipt_ids=None):
    return {
        "name": name,
        "bundleId": bundle_id,
        "appPath": app_path,
        "executableName": executable,
        "embeddedBundleIds": embedded or [],
        "teamId": team,
        "appGroups": groups or [],
        "icloudContainers": icloud or [],
        "isSandboxed": sandboxed,
        "receiptIds": receipt_ids or [],
    }


def fixture(file, name, ident, tree, strong, weak=(), absent=(), empty=(), casks=(), notes="", options=None,
            containers=None, launchd=None, receipts=None):
    data = {
        "schema": 1,
        "name": name,
        "status": "curated",
        "notes": notes,
        "home": "/Users/test",
        "identity": ident,
        "options": options or {"includeSystemLocations": False, "includeAggressiveLocations": False, "useCaskDatabase": True},
        "tree": sorted(set(tree)),
        "emptyDirs": sorted(set(empty)),
        "containerIdentifiers": containers,
        "launchdPrograms": launchd,
        "receipts": receipts,
        "expect": {
            "strong": sorted(set(strong)),
            "weak": sorted(set(weak)),
            "absent": sorted(set(absent)),
            "caskTokens": list(casks),
        },
    }
    path = os.path.join(OUT, file)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write("\n")
    return path


os.makedirs(OUT, exist_ok=True)

# ---------------------------------------------------------------- Google Chrome
chrome_strong = [
    "~/Library/Preferences/com.google.Chrome.plist",
    "~/Library/Application Support/Google/Chrome/",
    "~/Library/Caches/Google/Chrome/",
]
# Keystone (Google'ın ortak güncelleyicisi) birden fazla Google cask'inde geçer → paylaşılan, seçimsiz
chrome_weak = [
    "~/Library/Logs/DiagnosticReports/ExcUserFault_Google Chrome-2026-10-14-140258.ips",
    "~/Library/Preferences/com.google.Keystone.Agent.plist",
    "~/Library/Google/GoogleSoftwareUpdate/",
    "~/Library/Google/Google Chrome Brand.plist",
    "~/Library/LaunchAgents/com.google.keystone.agent.plist",
    "~/Library/LaunchAgents/com.google.keystone.xpcservice.plist",
]
chrome_absent = [
    "~/Library/Caches/com.apple.nsurlsessiond/Downloads/com.google.Chrome/",
    "~/Library/Preferences/com.google.Chrome.canary.plist",
    "~/Library/Application Support/Google/Chrome Canary/",
    "~/Library/Caches/Google/GoogleUpdater/",
    "~/Library/Caches/com.google.GoogleUpdater/",
    "~/Library/Application Support/Google/DriveFS/",
    "~/Library/Caches/com.apple.Safari/",
    "~/Library/Preferences/com.apple.Accessibility.plist",
]
fixture(
    "google-chrome.json", "Google Chrome — geliştirici klasörü içinde veri, kanal türevi, Keystone",
    identity("Google Chrome", "com.google.Chrome", "/Applications/Google Chrome.app", "Google Chrome"),
    tree=chrome_strong + chrome_weak + [p for p in chrome_absent if not p.endswith("Downloads/com.google.Chrome/")],
    strong=[p.rstrip("/") for p in chrome_strong],
    weak=[p.rstrip("/") for p in chrome_weak],
    absent=[p.rstrip("/") for p in chrome_absent],
    empty=["~/Library/Caches/com.apple.nsurlsessiond/Downloads/com.google.Chrome/"],
    casks=["google-chrome"],
    notes="Rapor 2026-10-21 build 9. ~/Library/Google ve Keystone yalnızca Homebrew verisiyle bulunur; başka Google cask'leri de sahiplendiği için paylaşılan sayılıp seçimsiz gelir.",
)

# ---------------------------------------------------------------- Microsoft Teams
teams_strong = [
    "~/Library/Preferences/com.microsoft.teams2.helper.plist",
    "~/Library/Preferences/com.microsoft.teams2.installer_telemetry.appdata.plist",
    "~/Library/Application Support/Microsoft/MSTeams/",
    "~/Library/Containers/com.microsoft.teams2/",
    "~/Library/Containers/com.microsoft.teams2.agent/",
    "~/Library/Containers/com.microsoft.teams2.notificationcenter/",
    "~/Library/Containers/com.microsoft.teams2.respawn/",
    "~/Library/Containers/com.microsoft.teams2.widgetextension/",
    "~/Library/Caches/com.microsoft.teams2.installer_telemetry/",
    "~/Library/HTTPStorages/com.microsoft.teams2.installer_telemetry/",
    "~/Library/Group Containers/UBF8T346G9.com.microsoft.teams/",
]
teams_empty = [
    "~/Library/Application Scripts/com.microsoft.teams2/",
    "~/Library/Application Scripts/com.microsoft.teams2.agent/",
    "~/Library/Application Scripts/UBF8T346G9.com.microsoft.teams/",
    "~/Library/Containers/com.microsoft.teams2.notificationcenter/",
    "~/Library/Containers/com.microsoft.teams2.respawn/",
]
teams_weak = ["~/Library/Group Containers/UBF8T346G9.com.microsoft.oneauth/"]
teams_strong = [p for p in teams_strong if p not in ("~/Library/Containers/com.microsoft.teams2.notificationcenter/", "~/Library/Containers/com.microsoft.teams2.respawn/")]
teams_absent = [
    "~/Library/Containers/com.microsoft.Outlook/",
    "~/Library/Application Support/Microsoft/Office/",
    "~/Library/Caches/com.microsoft.autoupdate2/",
    "~/Library/Preferences/com.microsoft.office.plist",
    "~/Library/Group Containers/UBF8T346G9.Office/",
] + teams_empty
fixture(
    "microsoft-teams.json", "Microsoft Teams — takım-ID önekli grup konteyneri, paylaşılan Office/AutoUpdate",
    identity("Microsoft Teams", "com.microsoft.teams2", "/Applications/Microsoft Teams.app", "MSTeams",
             embedded=["com.microsoft.teams2.helper", "com.microsoft.teams2.modulehost", "com.microsoft.teams2.notificationcenter2",
                       "com.microsoft.teams2.teamsswitcher", "com.microsoft.teams2.notificationcenter", "com.microsoft.vcxpc",
                       "com.microsoft.teams2.widgetextension"],
             team="UBF8T346G9", groups=["UBF8T346G9.com.microsoft.teams", "UBF8T346G9.com.microsoft.oneauth", "UBF8T346G9.com.microsoft.entrabroker"], sandboxed=True),
    tree=teams_strong + teams_weak + [p for p in teams_absent if p not in teams_empty],
    strong=[p.rstrip("/") for p in teams_strong],
    weak=[p.rstrip("/") for p in teams_weak],
    absent=[p.rstrip("/") for p in teams_absent],
    empty=teams_empty,
    casks=["microsoft-teams"],
    notes="Rapor 2026-10-21 build 9. oneauth grubu Microsoft'un ortak kimlik grubu (Outlook/OneDrive ile paylaşılır): entitlement'ta geçse de adı uygulamaya özgü olmadığı için zayıf.",
)

# ---------------------------------------------------------------- Logi Options+
logi_strong = [
    "~/Library/Preferences/com.logi.optionsplus.driverhost.plist",
    "~/Library/Preferences/com.logi.optionsplus.plist",
    "~/Library/Preferences/com.logi.pluginservice.plist",
    "~/Library/Preferences/com.logi.cp-dev-mgr.plist",
    "~/Library/Preferences/com.logi.lps.settings.plist",
    "~/Library/Application Support/LogiOptionsPlus/",
    "~/Library/Application Support/Logi/",
    "~/Library/HTTPStorages/LogiPluginServiceNative/",
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.logi.optionsplus.sfl4",
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.logi.optionsplus.driverhost.sfl4",
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.logi.pluginservice.sfl4",
    "/Applications/Utilities/Logi Options+ Driver Installer.bundle/",
]
logi_weak = ["~/Library/Application Support/CrashReporter/logioptionsplus_agent_7214F14B-116C-5737-A4C1-6F18619B1E3F.plist"]
logi_empty = ["~/Library/Caches/com.logi.optionsplus.installer/", "~/Library/Logs/xlog_logitech/"]
logi_absent = [
    "~/Library/Preferences/com.apple.loginwindow.plist",
    "~/Library/Application Support/Logic/",
    "~/Library/Caches/com.apple.logic10/",
    "/Library/Application Support/Logi/",
    "/Library/Application Support/Logitech.localized/LogiOptionsPlus/",
    "~/Library/Application Support/Logitech/Logitech Options/",
] + logi_empty
fixture(
    "logi-options-plus.json", "Logi Options+ — Homebrew'un bildiği gizli kalıntılar, sürücü kurucu .bundle, 'logi' ⊂ 'login/logic' tuzağı",
    identity("Logi Options+", "com.logi.optionsplus", "/Applications/logioptionsplus.app", "logioptionsplus", embedded=["com.logi.optionsplus.helper"], team="QED4VVPZWA"),
    tree=logi_strong + logi_weak + [p for p in logi_absent if p not in logi_empty],
    strong=[p.rstrip("/") for p in logi_strong],
    weak=logi_weak,
    absent=[p.rstrip("/") for p in logi_absent],
    empty=logi_empty,
    casks=["logi-options+"],
    notes="Rapor 2026-10-20 build 7. /Library yolları sistem taraması kapalıyken listelenmez; 'Logitech Options' eski uygulama (logitech-options cask) ayrı tutulur.",
)

# ---------------------------------------------------------------- PdfCraft / ArtCraft (aynı geliştirici)
fixture(
    "pdfcraft.json", "PdfCraft — aynı geliştiricinin diğer uygulaması listelenmez",
    identity("PdfCraft", "ai.storyteller.pdfcraft", "/Applications/PdfCraft.app", "PdfCraft"),
    tree=["~/Library/Preferences/ai.storyteller.pdfcraft.plist", "~/Library/Application Support/PdfCraft/",
          "~/Library/Application Support/ai.storyteller.artcraft-launcher/", "~/Library/Caches/ArtCraft Launcher/"],
    strong=["~/Library/Preferences/ai.storyteller.pdfcraft.plist", "~/Library/Application Support/PdfCraft"],
    absent=["~/Library/Application Support/ai.storyteller.artcraft-launcher", "~/Library/Caches/ArtCraft Launcher"],
    casks=["pdfcraft"],
    notes="Rapor 2026-10-20. Homebrew kaydı var (pdfcraft); ~/.local/share/pdfcraft zayıf olarak gelir.",
)
fixture(
    "artcraft-launcher.json", "ArtCraft Launcher — iki kelimeli ad, bundle ID'de tire",
    identity("ArtCraft Launcher", "ai.storyteller.artcraft-launcher", "/Applications/ArtCraft Launcher.app", "ArtCraft Launcher"),
    tree=["~/Library/Application Support/ai.storyteller.artcraft-launcher/", "~/Library/Caches/ArtCraft Launcher/",
          "~/Library/Application Support/PdfCraft/", "~/Library/Preferences/ai.storyteller.pdfcraft.plist"],
    strong=["~/Library/Application Support/ai.storyteller.artcraft-launcher", "~/Library/Caches/ArtCraft Launcher"],
    absent=["~/Library/Application Support/PdfCraft", "~/Library/Preferences/ai.storyteller.pdfcraft.plist"],
    casks=["artcraft-launcher"],
    notes="Rapor 2026-10-20. Homebrew kaydı var (artcraft-launcher).",
)

# ---------------------------------------------------------------- Video Evaluator (sandbox'lı küçük uygulama)
fixture(
    "video-evaluator.json", "Video Evaluator — sandbox konteyneri, 'video' genel kelimesi",
    identity("Video Evaluator", "com.koraybirand.Video-Evaluator", "/Applications/Video Evaluator.app", "Video Evaluator"),
    tree=["~/Library/Containers/com.koraybirand.Video-Evaluator/", "~/Library/Caches/com.apple.VideoConference/", "~/Library/Logs/Video/"],
    strong=["~/Library/Containers/com.koraybirand.Video-Evaluator"],
    absent=["~/Library/Application Scripts/com.koraybirand.Video-Evaluator", "~/Library/Caches/com.apple.VideoConference", "~/Library/Logs/Video"],
    empty=["~/Library/Application Scripts/com.koraybirand.Video-Evaluator/"],
    notes="Rapor 2026-10-20.",
)

# ---------------------------------------------------------------- OpenFan (bundle ID'nin son parçası 'app')
fixture(
    "openfan.json", "OpenFan — 'app' ⊂ 'apple' tuzağı (ilk sürümde 2.220 yanlış pozitif)",
    identity("OpenFan", "com.openfan.app", "/Applications/OpenFan.app", "OpenFan"),
    tree=["~/Library/Preferences/com.openfan.app.plist", "~/Library/Application Support/OpenFan/",
          "~/Library/Preferences/com.apple.Accessibility.plist", "~/Library/Preferences/com.apple.AccessibilityHearingNearby.plist",
          "~/Library/Caches/com.apple.appstore/", "~/Library/Application Support/App Store/", "~/Library/Caches/com.apple.appstoreagent/"],
    strong=["~/Library/Preferences/com.openfan.app.plist", "~/Library/Application Support/OpenFan"],
    absent=["~/Library/Preferences/com.apple.Accessibility.plist", "~/Library/Preferences/com.apple.AccessibilityHearingNearby.plist",
            "~/Library/Caches/com.apple.appstore", "~/Library/Application Support/App Store", "~/Library/Caches/com.apple.appstoreagent"],
    notes="Rapor 2026-10-18.",
)

# ---------------------------------------------------------------- Notion (Electron; kardeş uygulamalar Notion Calendar / Notion Mail)
notion_strong = [
    "~/Library/Preferences/notion.id.plist",
    "~/Library/Preferences/ByHost/notion.id.ShipIt.7214F14B-116C-5737-A4C1-6F18619B1E3F.plist",
    "~/Library/Application Support/Notion/",
    "~/Library/Application Support/Caches/notion-updater/",
    "~/Library/Caches/notion.id/",
    "~/Library/Caches/notion.id.ShipIt/",
    "~/Library/Logs/Notion/",
    "~/Library/HTTPStorages/notion.id/",
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/notion.id.sfl4",
]
notion_weak = ["~/Library/Caches/notion-updater/"]
notion_absent = [
    "~/Library/Application Support/Notion Calendar/",
    "~/Library/Application Support/Notion Mail/",
    "~/Library/Logs/Notion Mail/",
    "~/Library/Preferences/com.cron.electron.plist",
    "~/Library/Preferences/notion.mail.id.plist",
]
fixture(
    "notion.json", "Notion — Electron güncelleyici cache'i zayıf; Notion Calendar/Mail başka uygulama (Homebrew negatif kanıt)",
    identity("Notion", "notion.id", "/Applications/Notion.app", "Notion", embedded=["notion.id.helper"]),
    tree=notion_strong + notion_weak + notion_absent,
    strong=[p.rstrip("/") for p in notion_strong],
    weak=[p.rstrip("/") for p in notion_weak],
    absent=[p.rstrip("/") for p in notion_absent],
    casks=["notion"],
    notes="Rapor 2026-10-20 build 7. 'Notion Calendar' ad benzerliğiyle zayıf çıkardı; notion-calendar cask'i sahiplendiği için elenir.",
)

# ---------------------------------------------------------------- PanelGuard (kendi uygulaması, Homebrew'da yok)
fixture(
    "panelguard.json", "PanelGuard — küçük yerel uygulama, yalnızca tercih dosyası",
    identity("PanelGuard", "com.panelguard.app", "/Applications/PanelGuard.app", "PanelGuard"),
    tree=["~/Library/Preferences/com.panelguard.app.plist", "~/Library/Preferences/com.apple.panel.plist", "~/Library/Caches/com.apple.appstore/"],
    strong=["~/Library/Preferences/com.panelguard.app.plist"],
    absent=["~/Library/Preferences/com.apple.panel.plist", "~/Library/Caches/com.apple.appstore"],
    notes="Rapor 2026-10-20 build 7.",
)

# ---------------------------------------------------------------- Brave (Chromium, geliştirici klasörü, yalnızca Homebrew ile bilinen cache)
fixture(
    "brave-browser.json", "Brave — BraveSoftware/Brave-Browser geliştirici klasörü, Beta kanalı ayrı uygulama",
    identity("Brave Browser", "com.brave.Browser", "/Applications/Brave Browser.app", "Brave Browser"),
    tree=["~/Library/Application Support/BraveSoftware/Brave-Browser/", "~/Library/Caches/BraveSoftware/Brave-Browser/",
          "~/Library/Caches/com.brave.Browser/", "~/Library/Preferences/com.brave.Browser.plist",
          "~/Library/Application Support/BraveSoftware/Brave-Browser-Beta/", "~/Library/Application Support/Google/Chrome/"],
    strong=["~/Library/Application Support/BraveSoftware/Brave-Browser", "~/Library/Caches/BraveSoftware/Brave-Browser",
            "~/Library/Caches/com.brave.Browser", "~/Library/Preferences/com.brave.Browser.plist"],
    absent=["~/Library/Application Support/BraveSoftware/Brave-Browser-Beta", "~/Library/Application Support/Google/Chrome"],
    casks=["brave-browser"],
    notes="Sentetik vaka; Homebrew zap listesinden.",
)

print("fixtures written to", os.path.abspath(OUT))

# ================================================================ Tur B — kesin kaynaklar
# Teams, veritabanı KAPALI: grup konteyneri entitlements'tan bulunmalı
fixture(
    "microsoft-teams-nocask.json", "Microsoft Teams (veritabanı kapalı) — app group entitlements'tan, konteynerler bundle ID'den",
    identity("Microsoft Teams", "com.microsoft.teams2", "/Applications/Microsoft Teams.app", "MSTeams",
             embedded=["com.microsoft.teams2.helper", "com.microsoft.teams2.notificationcenter", "com.microsoft.vcxpc"],
             team="UBF8T346G9", groups=["UBF8T346G9.com.microsoft.teams", "UBF8T346G9.com.microsoft.oneauth"], sandboxed=True),
    tree=teams_strong + teams_weak + [p for p in teams_absent if p not in teams_empty],
    strong=[p.rstrip("/") for p in teams_strong],
    weak=[p.rstrip("/") for p in teams_weak],
    absent=[p.rstrip("/") for p in teams_absent],
    empty=teams_empty,
    options={"includeSystemLocations": False, "includeAggressiveLocations": False, "useCaskDatabase": False},
    notes="Sentetik varyant: Homebrew olmadan da UBF8T346G9.com.microsoft.teams güçlü olmalı (entitlement).",
)

# launchd: etiket adı uygulamayla ilgisiz, programı paket içinde
fixture(
    "launchd-program-inside-bundle.json", "launchd — plist etiketi farklı, programı uygulama paketinin içinde",
    identity("Acme Sync", "com.acme.sync", "/Applications/Acme Sync.app", "Acme Sync"),
    tree=["~/Library/Preferences/com.acme.sync.plist", "~/Library/LaunchAgents/io.vendor.helper-agent.plist",
          "~/Library/LaunchAgents/com.other.agent.plist"],
    strong=["~/Library/Preferences/com.acme.sync.plist", "~/Library/LaunchAgents/io.vendor.helper-agent.plist"],
    absent=["~/Library/LaunchAgents/com.other.agent.plist"],
    launchd={"~/Library/LaunchAgents/io.vendor.helper-agent.plist": "/Applications/Acme Sync.app/Contents/MacOS/sync-agent",
             "~/Library/LaunchAgents/com.other.agent.plist": "/Applications/Other.app/Contents/MacOS/other-agent"},
    notes="Sentetik. Program yolu paketin içini gösteren launchd kaydı etiketinden bağımsız olarak kesindir.",
)

# Konteyner metadata: UUID adlı konteyner, sahibi bundle ID'den
fixture(
    "container-metadata-uuid.json", "Konteyner metadata — UUID adlı konteynerin sahibi metadata'dan okunur",
    identity("Acme Notes", "com.acme.notes", "/Applications/Acme Notes.app", "Acme Notes",
             embedded=["com.acme.notes.ShareExtension"], sandboxed=True),
    tree=["~/Library/Containers/3F2504E0-4F89-11D3-9A0C-0305E82C3301/", "~/Library/Containers/7D0C4F2A-1B2C-4D3E-8F90-123456789ABC/",
          "~/Library/Containers/com.acme.notes.ShareExtension/", "~/Library/Application Scripts/com.acme.notes.ShareExtension/"],
    strong=["~/Library/Containers/3F2504E0-4F89-11D3-9A0C-0305E82C3301", "~/Library/Containers/com.acme.notes.ShareExtension",
            "~/Library/Application Scripts/com.acme.notes.ShareExtension"],
    absent=["~/Library/Containers/7D0C4F2A-1B2C-4D3E-8F90-123456789ABC"],
    containers={"~/Library/Containers/3F2504E0-4F89-11D3-9A0C-0305E82C3301": "com.acme.notes",
                "~/Library/Containers/7D0C4F2A-1B2C-4D3E-8F90-123456789ABC": "com.other.app"},
    notes="Sentetik. Ad eşleşmesi UUID klasörleri bulamaz; metadata bulur.",
)

# Kurulum faturaları (sistem taraması açık)
fixture(
    "receipts-pkgutil.json", "pkgutil — paketin /Library altına kurduğu dosyalar ve fatura dosyası (sistem taraması açık)",
    identity("Acme Driver", "com.acme.driver", "/Applications/Acme Driver.app", "Acme Driver"),
    tree=["~/Library/Preferences/com.acme.driver.plist", "/Library/Application Support/Acme/driver.kext/",
          "/Library/LaunchDaemons/com.acme.driverd.plist", "/Library/Application Support/Other/x.dat",
          "/private/var/db/receipts/com.acme.driver.pkg.bom", "/private/var/db/receipts/com.acme.driver.pkg.plist",
          "/private/var/db/receipts/com.other.pkg.bom"],
    strong=["~/Library/Preferences/com.acme.driver.plist", "/Library/Application Support/Acme",
            "/Library/LaunchDaemons/com.acme.driverd.plist",
            "/private/var/db/receipts/com.acme.driver.pkg.bom", "/private/var/db/receipts/com.acme.driver.pkg.plist"],
    absent=["/Library/Application Support/Other", "/private/var/db/receipts/com.other.pkg.bom"],
    options={"includeSystemLocations": True, "includeAggressiveLocations": False, "useCaskDatabase": True},
    receipts={"com.acme.driver.pkg": ["/Library/Application Support/Acme/driver.kext/Contents/Info.plist",
                                      "/Library/LaunchDaemons/com.acme.driverd.plist",
                                      "/Applications/Acme Driver.app/Contents/MacOS/Acme Driver"],
              "com.other.pkg": ["/Library/Application Support/Other/x.dat"]},
    notes="Sentetik. Faturadaki dosyalar standart kökün altındaki ilk bileşene indirgenir.",
)

# ================================================================ build 9 gözlemleri (2026-10-21)
fixture(
    "whatsapp.json", "WhatsApp — sandbox; satıcı ortak grubu (facebook.family) zayıf, kendi grupları güçlü",
    identity("WhatsApp", "net.whatsapp.WhatsApp", "/Applications/WhatsApp.app", "WhatsApp",
             embedded=["net.whatsapp.WhatsApp.ServiceExtension", "net.whatsapp.WhatsApp.Intents"], team="57T9237FN3",
             groups=["group.net.whatsapp.WhatsApp.shared", "group.net.whatsapp.WhatsAppSMB.shared", "group.net.whatsapp.WhatsApp.private",
                     "group.net.whatsapp.family", "group.com.facebook.family"],
             icloud=["57T9237FN3.net.whatsapp.WhatsApp", "iCloud.net.whatsapp.WhatsApp"], sandboxed=True),
    tree=["~/Library/Containers/net.whatsapp.WhatsApp/", "~/Library/Containers/net.whatsapp.WhatsApp.WAAppKitBridgeService/",
          "~/Library/Group Containers/group.net.whatsapp.WhatsApp.private/", "~/Library/Group Containers/group.net.whatsapp.WhatsApp.shared/",
          "~/Library/Group Containers/group.com.facebook.family/", "~/Library/Containers/com.facebook.archon/"],
    strong=["~/Library/Containers/net.whatsapp.WhatsApp", "~/Library/Containers/net.whatsapp.WhatsApp.WAAppKitBridgeService",
            "~/Library/Group Containers/group.net.whatsapp.WhatsApp.private", "~/Library/Group Containers/group.net.whatsapp.WhatsApp.shared",
            "~/Library/Group Containers/group.com.facebook.family"],
    absent=["~/Library/Containers/com.facebook.archon", "~/Library/Containers/net.whatsapp.WhatsApp.Intents",
            "~/Library/Group Containers/group.net.whatsapp.family"],
    empty=["~/Library/Containers/net.whatsapp.WhatsApp.Intents/", "~/Library/Containers/net.whatsapp.WhatsApp.ServiceExtension/",
           "~/Library/Group Containers/group.net.whatsapp.WhatsAppSMB.shared/", "~/Library/Group Containers/group.net.whatsapp.family/",
           "~/Library/Application Scripts/net.whatsapp.WhatsApp/", "~/Library/Application Scripts/group.net.whatsapp.WhatsApp.shared/"],
    casks=["whatsapp"],
    notes="Rapor 2026-10-21 build 9. group.com.facebook.family entitlement sezgiselinde zayıf kalırdı; Homebrew yalnızca whatsapp cask'inde listelediği için güçlü sayılır.",
)

fixture(
    "upnote.json", "UpNote — Homebrew'da yok; sandbox konteyneri, iOS ile paylaşılan grup, Son Belgeler kaydı",
    identity("UpNote", "com.getupnote.desktop", "/Applications/UpNote.app", "UpNote",
             embedded=["com.getupnote.desktop.loginhelper", "com.getupnote.desktop.helper", "com.getupnote.desktop.helper.Renderer",
                       "com.getupnote.desktop.helper.Plugin", "com.getupnote.desktop.helper.GPU"],
             team="78LWHGWLUL", groups=["group.com.getupnote.ios", "78LWHGWLUL.com.getupnote.desktop"], sandboxed=True),
    tree=["~/Library/Containers/com.getupnote.desktop/", "~/Library/Group Containers/group.com.getupnote.ios/",
          "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.getupnote.desktop.sfl4",
          "~/Library/Containers/com.getupnote.other/"],
    strong=["~/Library/Containers/com.getupnote.desktop", "~/Library/Group Containers/group.com.getupnote.ios",
            "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.getupnote.desktop.sfl4"],
    absent=["~/Library/Containers/com.getupnote.other", "~/Library/Group Containers/78LWHGWLUL.com.getupnote.desktop"],
    empty=["~/Library/Group Containers/78LWHGWLUL.com.getupnote.desktop/", "~/Library/Application Scripts/com.getupnote.desktop/"],
    notes="Rapor 2026-10-21 build 9. Satıcı adı uygulama adını içerdiği için (getupnote ⊃ upnote) grup uygulamaya özgü sayılır.",
)

fixture(
    "logi-driver-installer-nested-app.json", "Logi Options+ Driver Installer — .bundle içindeki iç .app, 'driver' genel kelimesi",
    identity("Logi Options+ Driver Installer", "com.logi.optionsplus.driverhost",
             "/Applications/Utilities/Logi Options+ Driver Installer.bundle/Logi Options+ Driver Installer.app",
             "Logi Options+ Driver Installer", team="QED4VVPZWA"),
    tree=["~/Library/Preferences/com.logi.optionsplus.driverhost.plist", "~/Library/Preferences/com.logi.optionsplus.plist",
          "~/Library/Preferences/com.apple.driver.AppleHIDMouse.plist", "~/Library/Application Support/LogiOptionsPlus/",
          "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.logi.optionsplus.driverhost.sfl4"],
    strong=["~/Library/Preferences/com.logi.optionsplus.driverhost.plist",
            "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.logi.optionsplus.driverhost.sfl4"],
    absent=["~/Library/Preferences/com.logi.optionsplus.plist", "~/Library/Preferences/com.apple.driver.AppleHIDMouse.plist",
            "~/Library/Application Support/LogiOptionsPlus"],
    notes="Rapor 2026-10-21 build 9. Ana uygulamanın (optionsplus) dosyaları bu yardımcıya ait değildir.",
)
