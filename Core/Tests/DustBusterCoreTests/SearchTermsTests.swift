import XCTest
@testable import DustBusterCore

final class SearchTermsTests: XCTestCase {
    private func terms(bundleId: String, name: String) -> SearchTerms {
        SearchTerms(identity: AppIdentity(name: name, bundleId: bundleId, appPath: "/Applications/\(name).app"))
    }

    func testBundleIdForms() {
        let t = terms(bundleId: "ai.storyteller.pdfcraft", name: "PdfCraft")
        XCTAssertEqual(t.match("ai.storyteller.pdfcraft.plist"), .strong)
        XCTAssertEqual(t.match("ai.storyteller.pdfcraft.helper.plist"), .strong)
        XCTAssertEqual(t.match("group.ai.storyteller.pdfcraft", isDirectory: true), .strong)
        XCTAssertEqual(t.match("TEAMID.ai.storyteller.pdfcraft", isDirectory: true), .strong)
        XCTAssertNil(t.match("ai.storyteller.artcraft-launcher", isDirectory: true), "aynı geliştiricinin başka uygulaması")
        XCTAssertNil(t.match("storyteller", isDirectory: true), "geliştirici adı tek başına eşleşmez")
    }

    func testGenericLastComponentNeverMatches() {
        let t = terms(bundleId: "com.openfan.app", name: "OpenFan")
        XCTAssertNil(t.match("com.apple.Accessibility.plist"))
        XCTAssertNil(t.match("Applications", isDirectory: true))
        XCTAssertNil(t.match("appstore.plist"))
        XCTAssertEqual(t.match("com.openfan.app.plist"), .strong)
        XCTAssertEqual(t.match("OpenFan", isDirectory: true), .strong)
        XCTAssertEqual(t.match("OpenFan-2026-10-18-120000.ips"), .weak)
    }

    func testVendorFolderRelativePaths() {
        let t = terms(bundleId: "com.google.Chrome", name: "Google Chrome")
        XCTAssertNil(t.match("Google", isDirectory: true))
        XCTAssertEqual(t.match("Google/Chrome", isDirectory: true), .strong)
        XCTAssertNil(t.match("Google/GoogleUpdater", isDirectory: true))
        XCTAssertNil(t.match("Google/Chrome Canary", isDirectory: true), "kanal türevi ayrı uygulama")
        XCTAssertNil(t.match("com.google.Chrome.canary.plist"))
        XCTAssertEqual(t.match("com.google.Chrome.helper.plist"), .strong)
        XCTAssertEqual(t.match("ExcUserFault_Google Chrome-2026-10-14-140258.ips"), .weak)
        XCTAssertNil(t.match("Google/Chrome Canary/Default", isDirectory: true), "kanal klasörünün altı da eşleşmez")
        XCTAssertNil(t.match("Google/Chrome Remote Desktop/Default", isDirectory: true), "üst klasör adı kredilendirilmez")
        XCTAssertNil(t.match("Google/Chrome Remote Desktop", isDirectory: true))
    }

    func testCaskLookupPrefersSingleAppCaskOverSuite() throws {
        let db = try XCTUnwrap(CaskDatabase.bundled())
        let teams = AppIdentity(name: "Microsoft Teams", bundleId: "com.microsoft.teams2", appPath: "/Applications/Microsoft Teams.app", executableName: "MSTeams")
        let tokens = db.lookup(identity: teams).map { $0.token }
        XCTAssertTrue(tokens.contains("microsoft-teams"), "\(tokens)")
        XCTAssertFalse(tokens.contains("microsoft-office-businesspro"), "paket cask'i seçilmemeli: \(tokens)")
    }

    func testGenericNamesUseOnlyBundleId() {
        let t = terms(bundleId: "com.foo.reader", name: "Reader")
        XCTAssertTrue(t.nameTokenSets.isEmpty)
        XCTAssertNil(t.match("Reader", isDirectory: true))
        XCTAssertEqual(t.match("com.foo.reader.plist"), .strong)
        XCTAssertNil(t.match("com.foo.readerx.plist"))
    }

    func testAppleAppKeepsAppleNames() {
        let t = terms(bundleId: "com.apple.Notes", name: "Notes")
        XCTAssertEqual(t.match("com.apple.Notes.plist"), .strong)
        XCTAssertNil(t.match("Notes", isDirectory: true), "'notes' genel ad")
    }

    func testTwoWordNames() {
        let t = terms(bundleId: "com.microsoft.teams2", name: "Microsoft Teams")
        XCTAssertNil(t.match("Microsoft", isDirectory: true))
        XCTAssertNil(t.match("Microsoft/MSTeams", isDirectory: true), "yürütülebilir adı bilinmeden MSTeams eşleşmez")
        let withExe = SearchTerms(identity: AppIdentity(name: "Microsoft Teams", bundleId: "com.microsoft.teams2",
                                                        appPath: "/Applications/Microsoft Teams.app", executableName: "MSTeams"))
        XCTAssertEqual(withExe.match("Microsoft/MSTeams", isDirectory: true), .strong, "CFBundleExecutable ad varyantı olarak kullanılır")
        XCTAssertEqual(t.match("Microsoft Teams", isDirectory: true), .strong)
        XCTAssertNil(t.match("com.microsoft.ChromeHelper.plist"))
    }

    func testGlob() {
        XCTAssertTrue(Glob.matches("com.google.Chrome.helper.*", "com.google.Chrome.helper.renderer"))
        XCTAssertTrue(Glob.matches("*.com.microsoft.teams", "UBF8T346G9.com.microsoft.teams"))
        XCTAssertFalse(Glob.matches("*.com.microsoft.teams", "com.microsoft.teams2"))
        XCTAssertTrue(Glob.matches("com.microsoft.teams*", "com.microsoft.teams2.agent"))
        XCTAssertTrue(Glob.matches("firefox_*", "firefox_2026-10-01.crash"))
        XCTAssertFalse(Glob.matches("firefox_*", "thunderbird_2026.crash"))
        XCTAssertTrue(Glob.matches("notion.id*", "notion.id.ShipIt"))
    }

    func testGlobExpansionOverVirtualFileSystem() {
        let home = "/Users/test"
        let fs = VirtualFileSystem(paths: [
            "\(home)/Library/Containers/com.microsoft.teams2/",
            "\(home)/Library/Containers/com.microsoft.teams2.agent/",
            "\(home)/Library/Containers/com.apple.Notes/",
            "\(home)/Library/Group Containers/UBF8T346G9.com.microsoft.teams/",
            "\(home)/Library/Preferences/com.google.Chrome.plist"
        ])
        XCTAssertEqual(Glob.expand(pattern: "~/Library/Containers/com.microsoft.teams*", home: home, fs: fs),
                       ["\(home)/Library/Containers/com.microsoft.teams2", "\(home)/Library/Containers/com.microsoft.teams2.agent"])
        XCTAssertEqual(Glob.expand(pattern: "~/Library/Group Containers/*.com.microsoft.teams", home: home, fs: fs),
                       ["\(home)/Library/Group Containers/UBF8T346G9.com.microsoft.teams"])
        XCTAssertEqual(Glob.expand(pattern: "~/Library/Preferences/com.google.Chrome.plist", home: home, fs: fs),
                       ["\(home)/Library/Preferences/com.google.Chrome.plist"])
        XCTAssertEqual(Glob.expand(pattern: "~/Library/Preferences/com.google.Keystone.Agent.plist", home: home, fs: fs), [])
    }

    func testVirtualFileSystemShape() {
        let fs = VirtualFileSystem(paths: ["/Users/test/Library/Caches/Google/Chrome/", "/Users/test/Library/Preferences/a.plist"])
        XCTAssertTrue(fs.isDirectory("/Users/test/Library/Caches/Google"))
        XCTAssertTrue(fs.isDirectory("/Users/test/Library/Caches/Google/Chrome"))
        XCTAssertFalse(fs.isDirectory("/Users/test/Library/Preferences/a.plist"))
        XCTAssertEqual(fs.contents(ofDirectory: "/Users/test/Library")?.sorted(), ["Caches", "Preferences"])
        XCTAssertNil(fs.contents(ofDirectory: "/Users/test/Nope"))
    }

    func testPathAdmission() {
        let home = "/Users/test"
        let opts = ScanOptions()
        XCTAssertEqual(PathClassifier.admit(path: "\(home)/Library/Caches/x", home: home, options: opts), .accepted(.strong, note: nil))
        XCTAssertEqual(PathClassifier.admit(path: "\(home)/Library/Keychains/x", home: home, options: opts), .rejected(reason: "korunan kullanıcı verisi: ~/Library/Keychains"))
        XCTAssertEqual(PathClassifier.admit(path: "\(home)/Documents/Zoom", home: home, options: opts), .rejected(reason: "kullanıcı verisi (Belgeler, Masaüstü vb.)"))
        XCTAssertEqual(PathClassifier.admit(path: "\(home)/.zoomus", home: home, options: opts), .accepted(.weak, note: "ev dizininde gizli klasör — kontrol et"))
        XCTAssertEqual(PathClassifier.admit(path: "/Library/Logs/x", home: home, options: opts), .rejected(reason: "sistem konumu (/Library) — 'Sistem dosyalarını da tara' kapalı"))
        XCTAssertEqual(PathClassifier.admit(path: "/Library/Logs/x", home: home, options: ScanOptions(includeSystemLocations: true)), .accepted(.strong, note: "admin yetkisi gerekebilir"))
        XCTAssertEqual(PathClassifier.admit(path: "/Applications/Utilities/Logi Options+ Driver Installer.bundle", home: home, options: opts), .accepted(.strong, note: "Uygulamalar klasöründe ek bileşen"))
        XCTAssertEqual(PathClassifier.admit(path: "/Applications/Other.app", home: home, options: opts), .rejected(reason: "başka bir uygulama paketi"))
    }

    func testOtherOwnersFromCaskDatabase() throws {
        let db = try XCTUnwrap(CaskDatabase.bundled())
        let home = "/Users/test"
        XCTAssertEqual(db.otherOwners(ofPath: "\(home)/Library/Application Support/Notion Calendar", home: home, excluding: ["notion"]), ["notion-calendar"])
        XCTAssertEqual(db.otherOwners(ofPath: "\(home)/Library/Preferences/notion.mail.id.plist", home: home, excluding: ["notion"]), ["notion-mail"])
        XCTAssertTrue(db.otherOwners(ofPath: "\(home)/Library/Caches/notion-updater", home: home, excluding: ["notion"]).isEmpty, "aşırı geniş kalıplar sahiplik kanıtı sayılmaz")
        XCTAssertTrue(db.otherOwners(ofPath: "\(home)/Library/Application Support/Notion", home: home, excluding: ["notion"]).isEmpty)
    }

    func testEffectivelyEmptyDirectory() {
        let fs = VirtualFileSystem(paths: [
            "/x/onlyEmptySubdirs/a/b/",
            "/x/onlyEmptySubdirs/c/",
            "/x/hasFile/a/file.txt",
            "/x/empty/"
        ])
        XCTAssertTrue(fs.isEffectivelyEmptyDirectory("/x/onlyEmptySubdirs"))
        XCTAssertTrue(fs.isEffectivelyEmptyDirectory("/x/empty"))
        XCTAssertFalse(fs.isEffectivelyEmptyDirectory("/x/hasFile"))
        XCTAssertFalse(fs.isEffectivelyEmptyDirectory("/x/hasFile/a/file.txt"))
    }
}
