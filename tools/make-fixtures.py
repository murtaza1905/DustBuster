#!/usr/bin/env python3
"""
Core/Tests/DustBusterCoreTests/Fixtures altındaki vaka dosyalarını üretir. Vakalar 2026-10-18/20 tarihli gerçek
taramalardan alınmış, negatif kontrollerle (listelenmemesi gereken yollar) genişletilmiştir.

Kullanım: python3 tools/make-fixtures.py
"""
import json
import os

OUT = os.path.join(os.path.dirname(__file__), "..", "Core", "Tests", "DustBusterCoreTests", "Fixtures")


def identity(name, bundle_id, app_path, executable=None, embedded=None):
    return {
        "name": name,
        "bundleId": bundle_id,
        "appPath": app_path,
        "executableName": executable,
        "embeddedBundleIds": embedded or [],
        "teamId": None,
        "appGroups": [],
    }


def fixture(file, name, ident, tree, strong, weak=(), absent=(), empty=(), casks=(), notes="", options=None):
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
    "~/Library/Preferences/com.google.Keystone.Agent.plist",
    "~/Library/Application Support/Google/Chrome/",
    "~/Library/Caches/Google/Chrome/",
    "~/Library/Google/GoogleSoftwareUpdate/",
    "~/Library/Google/Google Chrome Brand.plist",
    "~/Library/LaunchAgents/com.google.keystone.agent.plist",
    "~/Library/LaunchAgents/com.google.keystone.xpcservice.plist",
]
chrome_weak = ["~/Library/Logs/DiagnosticReports/ExcUserFault_Google Chrome-2026-10-14-140258.ips"]
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
    weak=chrome_weak,
    absent=[p.rstrip("/") for p in chrome_absent],
    empty=["~/Library/Caches/com.apple.nsurlsessiond/Downloads/com.google.Chrome/"],
    casks=["google-chrome"],
    notes="Rapor 2026-10-20 (build 6 gözlemiyle birleştirildi). ~/Library/Google ve Keystone yalnızca Homebrew verisiyle bulunur.",
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
]
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
                       "com.microsoft.teams2.widgetextension"]),
    tree=teams_strong + [p for p in teams_absent if p not in teams_empty],
    strong=[p.rstrip("/") for p in teams_strong],
    absent=[p.rstrip("/") for p in teams_absent],
    empty=teams_empty,
    casks=["microsoft-teams"],
    notes="Rapor 2026-10-20 (build 6 gözlemiyle birleştirildi). UBF8T346G9.com.microsoft.teams Homebrew zap ile güçlü; boş Application Scripts dizinleri listelenmez.",
)

# ---------------------------------------------------------------- Logi Options+
logi_strong = [
    "~/Library/Preferences/com.logi.optionsplus.driverhost.plist",
    "~/Library/Preferences/com.logi.optionsplus.plist",
    "~/Library/Preferences/com.logi.pluginservice.plist",
    "~/Library/Application Support/LogiOptionsPlus/",
    "~/Library/Application Support/Logi/",
    "~/Library/Logs/xlog_logitech/",
]
logi_weak = ["~/Library/Application Support/CrashReporter/logioptionsplus_agent_7214F14B-116C-5737-A4C1-6F18619B1E3F.plist"]
logi_empty = ["~/Library/Caches/com.logi.optionsplus.installer/"]
logi_strong.append("~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.logi.optionsplus.sfl4")
logi_absent = [
    "~/Library/Preferences/com.apple.loginwindow.plist",
    "~/Library/Application Support/Logic/",
    "~/Library/Caches/com.apple.logic10/",
] + logi_empty
fixture(
    "logi-options-plus.json", "Logi Options+ — Homebrew'un bildiği gizli kalıntılar (xlog_logitech, pluginservice), 'logi' ⊂ 'login/logic' tuzağı",
    identity("Logi Options+", "com.logi.optionsplus", "/Applications/logioptionsplus.app"),
    tree=logi_strong + logi_weak + [p for p in logi_absent if p not in logi_empty],
    strong=[p.rstrip("/") for p in logi_strong],
    weak=logi_weak,
    absent=[p.rstrip("/") for p in logi_absent],
    empty=logi_empty,
    casks=["logi-options+"],
    notes="Rapor 2026-10-20. Son Belgeler kaydı (sfl4) geniş tarama kapalıyken yalnızca Homebrew verisiyle bulunur.",
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
