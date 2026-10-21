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

    func testReceiptMatching() {
        let identity = AppIdentity(name: "Acme Driver", bundleId: "com.acme.driver", appPath: "/Applications/Acme Driver.app",
                                   embeddedBundleIds: ["com.acme.driver.helper"])
        let all = ["com.acme.driver.pkg", "com.acme.driver.helper.pkg", "com.acme.other.pkg", "com.apple.pkg.CLTools", "io.vendor.AcmeAudio"]
        XCTAssertEqual(ReceiptMatcher.matchingPackageIds(all: all, identity: identity, caskPkgIds: ["io.vendor.Acme*"]),
                       ["com.acme.driver.pkg", "com.acme.driver.helper.pkg", "io.vendor.AcmeAudio"])
        let collapsed = ReceiptMatcher.collapse(files: [
            "/Library/Application Support/Acme/driver.kext/Contents/Info.plist",
            "/Library/Application Support/Acme/driver.kext/Contents/MacOS/driver",
            "/Library/LaunchDaemons/com.acme.driverd.plist",
            "/Applications/Acme Driver.app/Contents/MacOS/Acme Driver",
            "/Applications/Utilities/Acme Tool.app/Contents/Info.plist",
            "/usr/local/bin/acme",
            "relative/path"
        ], appPath: "/Applications/Acme Driver.app", home: "/Users/test")
        XCTAssertEqual(collapsed, ["/Library/Application Support/Acme", "/Library/LaunchDaemons/com.acme.driverd.plist",
                                   "/Applications/Utilities/Acme Tool.app", "/usr/local/bin/acme"])
    }

    func testVirtualFileSystemMetadataAndLaunchd() {
        let fs = VirtualFileSystem(paths: ["/Users/test/Library/Containers/ABC/", "/Users/test/Library/LaunchAgents/x.plist"],
                                   containerIdentifiers: ["/Users/test/Library/Containers/ABC": "com.acme.notes"],
                                   launchdPrograms: ["/Users/test/Library/LaunchAgents/x.plist": "/Applications/Acme.app/Contents/MacOS/x"])
        XCTAssertEqual(fs.containerIdentifier(ofContainerAt: "/Users/test/Library/Containers/ABC"), "com.acme.notes")
        XCTAssertNil(fs.containerIdentifier(ofContainerAt: "/Users/test/Library/Containers/other"))
        XCTAssertEqual(fs.launchdProgram(ofPlistAt: "/Users/test/Library/LaunchAgents/x.plist"), "/Applications/Acme.app/Contents/MacOS/x")
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

    func testLongNamePrefixMatchesWeakly() {
        let logi = terms(bundleId: "com.logi.pluginservice", name: "LogiPluginService")
        XCTAssertEqual(logi.match("LogiPluginServiceNative", isDirectory: true), .weak)
        XCTAssertEqual(logi.match("LogiPluginService", isDirectory: true), .strong)
        let short = terms(bundleId: "com.foo.app", name: "Noteful")
        XCTAssertNil(short.match("Notefulness", isDirectory: true), "8 karakterden kısa adlarda önek eşleşmesi yok")
        let xcode = terms(bundleId: "com.apple.dt.Xcode", name: "Xcode")
        XCTAssertNil(xcode.match("com.apple.dt.xcodebuild", isDirectory: true))
    }

    func testCaskLookupPrefersSpecificPkgCaskOverSuite() throws {
        let db = try XCTUnwrap(CaskDatabase.bundled())
        let excel = AppIdentity(name: "Microsoft Excel", bundleId: "com.microsoft.Excel", appPath: "/Applications/Microsoft Excel.app")
        XCTAssertEqual(db.lookup(identity: excel).map { $0.token }, ["microsoft-excel"])
        let word = AppIdentity(name: "Microsoft Word", bundleId: "com.microsoft.Word", appPath: "/Applications/Microsoft Word.app")
        XCTAssertEqual(db.lookup(identity: word).map { $0.token }, ["microsoft-word"])
        let ppt = AppIdentity(name: "Microsoft PowerPoint", bundleId: "com.microsoft.Powerpoint", appPath: "/Applications/Microsoft PowerPoint.app")
        XCTAssertEqual(db.lookup(identity: ppt).map { $0.token }, ["microsoft-powerpoint"])
        XCTAssertEqual(CaskDatabase.bundleLikeComponents(ofPattern: "~/Library/Containers/com.microsoft.Excel*"), ["com.microsoft.excel"])
        XCTAssertEqual(CaskDatabase.bundleLikeComponents(ofPattern: "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.microsoft.word.sfl*"), ["com.microsoft.word"])
        XCTAssertTrue(CaskDatabase.bundleLikeComponents(ofPattern: "~/Library/Application Support/Microsoft").isEmpty)
    }

    func testSameAppCasksAreNotOtherOwners() throws {
        let db = try XCTUnwrap(CaskDatabase.bundled())
        let home = "/Users/test"
        let ppt = AppIdentity(name: "Microsoft PowerPoint", bundleId: "com.microsoft.Powerpoint", appPath: "/Applications/Microsoft PowerPoint.app")
        XCTAssertTrue(db.otherOwners(ofPath: "\(home)/Library/Containers/com.microsoft.Powerpoint", home: home, excluding: ["microsoft-powerpoint"], identity: ppt).isEmpty,
                      "Office paketi PowerPoint.app'i taşıdığı için aynı uygulamadır")
        let chrome = AppIdentity(name: "Google Chrome", bundleId: "com.google.Chrome", appPath: "/Applications/Google Chrome.app")
        let keystone = db.otherOwners(ofPath: "\(home)/Library/LaunchAgents/com.google.keystone.agent.plist", home: home, excluding: ["google-chrome"], identity: chrome)
        XCTAssertTrue(keystone.contains("google-chrome@beta"), "Chrome Beta ayrı uygulamadır, Keystone paylaşılır: \(keystone)")
    }

    func testVendorFolderIsNeverAutoSelected() {
        let home = "/Users/test"
        let fs = VirtualFileSystem(paths: [
            "\(home)/Library/Application Support/Microsoft/MSTeams/x",
            "\(home)/Library/Application Support/Microsoft Word/x",
            "\(home)/Library/Application Support/Notion/x",
            "/Applications/Microsoft Word.app/Contents/Info.plist",
            "/Applications/Notion.app/Contents/Info.plist"
        ])
        let word = AppIdentity(name: "Microsoft Word", bundleId: "com.microsoft.Word", appPath: "/Applications/Microsoft Word.app")
        let wordResult = LeftoverScanner(home: home, fs: fs, caskDatabase: nil).scan(identity: word)
        XCTAssertEqual(wordResult.findings.first { $0.path == "\(home)/Library/Application Support/Microsoft Word" }?.strength, .strong)
        XCTAssertFalse(wordResult.contains(path: "\(home)/Library/Application Support/Microsoft"), "ad eşleşmesi satıcı klasörünü bulmaz")
        let forced = AppConditions(conditions: [AppCondition(id: "word", bundleIds: ["com.microsoft.Word"],
                                                            include: [AppCondition.Include(path: "~/Library/Application Support/Microsoft")])])
        let forcedResult = LeftoverScanner(home: home, fs: fs, caskDatabase: nil, conditions: forced).scan(identity: word)
        let vendor = forcedResult.findings.first { $0.path == "\(home)/Library/Application Support/Microsoft" }
        XCTAssertEqual(vendor?.strength, .weak, "kaynağı ne olursa olsun satıcı klasörü seçimsiz")
        XCTAssertTrue(vendor?.note.contains("satıcı klasörü") ?? false)
        let notion = AppIdentity(name: "Notion", bundleId: "notion.id", appPath: "/Applications/Notion.app")
        let notionResult = LeftoverScanner(home: home, fs: fs, caskDatabase: nil).scan(identity: notion)
        XCTAssertEqual(notionResult.findings.first { $0.path == "\(home)/Library/Application Support/Notion" }?.strength, .strong, "uygulamanın adı satıcı adının kendisiyse klasör onundur")
        XCTAssertEqual(LeftoverScanner.vendorToken(identity: word), "microsoft")
        XCTAssertEqual(LeftoverScanner.vendorToken(identity: notion), "notion")
    }

    func testEmptyShellsAreListedFromDeterministicSourcesOnly() {
        let home = "/Users/test"
        let fs = VirtualFileSystem(paths: [
            "\(home)/Library/Application Scripts/com.demo.app/",
            "\(home)/Library/Containers/com.demo.app/Data/x",
            "\(home)/Library/Application Support/Demo Something/",
            "/Applications/Demo.app/Contents/Info.plist"
        ])
        let identity = AppIdentity(name: "Demo", bundleId: "com.demo.app", appPath: "/Applications/Demo.app")
        let result = LeftoverScanner(home: home, fs: fs, caskDatabase: nil).scan(identity: identity)
        let shell = result.findings.first { $0.path == "\(home)/Library/Application Scripts/com.demo.app" }
        XCTAssertEqual(shell?.strength, .strong, "bundle ID ile bulunan boş kabuk listelenir")
        XCTAssertTrue(shell?.note.contains("boş klasör") ?? false)
        XCTAssertFalse(result.findings.first { $0.path == "\(home)/Library/Containers/com.demo.app" }?.note.contains("boş klasör") ?? true)
        XCTAssertFalse(result.contains(path: "\(home)/Library/Application Support/Demo Something"), "ad benzerliğiyle bulunan boş klasör gürültüdür")
    }
}
