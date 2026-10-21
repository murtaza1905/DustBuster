import XCTest
@testable import DustBusterCore

final class ConditionsTests: XCTestCase {
    private let home = "/Users/test"

    func testBundledConditionsLoad() throws {
        let conditions = try XCTUnwrap(AppConditions.bundled(), "conditions.json yüklenemedi")
        XCTAssertGreaterThanOrEqual(conditions.count, 2)
        let xcode = AppIdentity(name: "Xcode", bundleId: "com.apple.dt.Xcode", appPath: "/Applications/Xcode.app")
        XCTAssertEqual(conditions.matching(identity: xcode, caskTokens: []).map { $0.id }, ["xcode"])
        let other = AppIdentity(name: "Xcodes", bundleId: "com.robotsandpencils.XcodesApp", appPath: "/Applications/Xcodes.app")
        XCTAssertTrue(conditions.matching(identity: other, caskTokens: []).isEmpty)
    }

    func testIncludeAddsAndExcludeRemovesFromAnySource() {
        let condition = AppCondition(
            id: "demo",
            bundleIds: ["com.demo.app"],
            include: [AppCondition.Include(path: "~/Library/Developer/Demo", strength: .strong, note: "derleme çıktısı"),
                      AppCondition.Include(path: "~/Library/Caches/org.demo.*", strength: .weak)],
            exclude: ["~/Library/Caches/com.demo.app"]
        )
        let conditions = AppConditions(conditions: [condition])
        let fs = VirtualFileSystem(paths: [
            "\(home)/Library/Caches/com.demo.app/x",
            "\(home)/Library/Preferences/com.demo.app.plist",
            "\(home)/Library/Developer/Demo/x",
            "\(home)/Library/Caches/org.demo.shared/x",
            "/Applications/Demo.app/Contents/Info.plist"
        ])
        let identity = AppIdentity(name: "Demo", bundleId: "com.demo.app", appPath: "/Applications/Demo.app")
        let scanner = LeftoverScanner(home: home, fs: fs, caskDatabase: nil, conditions: conditions)
        let result = scanner.scan(identity: identity)

        XCTAssertEqual(result.conditionIds, ["demo"])
        let developer = result.findings.first { $0.path == "\(home)/Library/Developer/Demo" }
        XCTAssertEqual(developer?.strength, .strong)
        XCTAssertEqual(developer?.source, .condition)
        XCTAssertTrue(developer?.note.contains("derleme çıktısı") ?? false)
        XCTAssertEqual(result.findings.first { $0.path == "\(home)/Library/Caches/org.demo.shared" }?.strength, .weak)
        XCTAssertTrue(result.contains(path: "\(home)/Library/Preferences/com.demo.app.plist"))
        XCTAssertFalse(result.contains(path: "\(home)/Library/Caches/com.demo.app"), "exclude kuralı birebir bulguyu da elemeli")
        XCTAssertTrue(result.rejected.contains { $0.path == "\(home)/Library/Caches/com.demo.app" && $0.reason.contains("demo") })
    }

    func testConditionMatchesByCaskToken() throws {
        let db = try XCTUnwrap(CaskDatabase.bundled())
        let condition = AppCondition(id: "notion-extra", caskTokens: ["notion"],
                                     include: [AppCondition.Include(path: "~/Library/Caches/notion-updater")])
        let fs = VirtualFileSystem(paths: ["\(home)/Library/Caches/notion-updater/x", "/Applications/Notion.app/Contents/Info.plist"])
        let identity = AppIdentity(name: "Notion", bundleId: "notion.id", appPath: "/Applications/Notion.app")
        let scanner = LeftoverScanner(home: home, fs: fs, caskDatabase: db, conditions: AppConditions(conditions: [condition]))
        let result = scanner.scan(identity: identity)
        XCTAssertEqual(result.caskTokens, ["notion"])
        XCTAssertEqual(result.conditionIds, ["notion-extra"])
        XCTAssertEqual(result.findings.first { $0.path == "\(home)/Library/Caches/notion-updater" }?.strength, .strong)
    }

    func testConditionNeverOverridesProtectedRoots() {
        let condition = AppCondition(id: "bad", bundleIds: ["com.demo.app"],
                                     include: [AppCondition.Include(path: "~/Library/Keychains"), AppCondition.Include(path: "~/Documents/Demo")])
        let fs = VirtualFileSystem(paths: ["\(home)/Library/Keychains/login.keychain-db", "\(home)/Documents/Demo/x", "/Applications/Demo.app/Contents/Info.plist"])
        let identity = AppIdentity(name: "Demo", bundleId: "com.demo.app", appPath: "/Applications/Demo.app")
        let result = LeftoverScanner(home: home, fs: fs, caskDatabase: nil, conditions: AppConditions(conditions: [condition])).scan(identity: identity)
        XCTAssertFalse(result.contains(path: "\(home)/Library/Keychains"))
        XCTAssertFalse(result.contains(path: "\(home)/Documents/Demo"))
        XCTAssertEqual(result.rejected.count, 2)
    }
}

final class CleanupRulesTests: XCTestCase {
    private let home = "/Users/test"

    private func makePolicy(paths: [String]) throws -> CleanupPolicy {
        let rules = try XCTUnwrap(CleanupRules.bundled(), "rules.json yüklenemedi")
        return CleanupPolicy(rules: rules, home: home, fs: VirtualFileSystem(paths: paths))
    }

    func testBundledRulesLoad() throws {
        let rules = try XCTUnwrap(CleanupRules.bundled())
        XCTAssertEqual(rules.roots.map { $0.path }, ["~/Library/Caches", "~/Library/Logs"])
        XCTAssertTrue(rules.vendorFolders.contains("Google"))
        XCTAssertTrue(rules.appleServiceNames.contains("GeoServices"))
        XCTAssertEqual(rules.browsers.chromiumNames["Google/Chrome"], "Google Chrome")
    }

    func testChromiumDetectionCoversCachesMirrorAndVendorSplit() throws {
        let lib = home + "/Library"
        let policy = try makePolicy(paths: [
            "\(lib)/Application Support/Google/Chrome/Local State",
            "\(lib)/Application Support/Google/Chrome/Default/GPUCache/data",
            "\(lib)/Application Support/Google/Chrome/Default/Cookies",
            "\(lib)/Application Support/Google/Chrome/Profile 1/GPUCache/data",
            "\(lib)/Application Support/Google/Chrome/ShaderCache/data",
            "\(lib)/Application Support/Google/DriveFS/x",
            "\(lib)/Application Support/Notion/x",
            "\(lib)/Caches/Google/Chrome/Default/Cache/data",
            "\(lib)/Caches/Google/Chrome/Default/Code Cache/js/data",
            "\(lib)/Caches/Google/Chrome/Default/Other/data",
            "\(lib)/Caches/Google/GoogleUpdater/x",
            "\(lib)/Caches/com.apple.helpd/x",
            "\(lib)/Caches/com.apple.dt.Xcode/x",
            "\(lib)/Caches/GeoServices/x",
            "\(lib)/Caches/notion.id/x",
            "\(lib)/Caches/Firefox/Profiles/abc.default/cache2/entries/x",
            "\(lib)/Caches/com.apple.Safari/x",
            "\(lib)/Caches/com.apple.Safari.SafeBrowsing/x",
            "\(lib)/Logs/Notion/x",
            "\(lib)/Logs/Microsoft/Teams/x"
        ])
        policy.detectChromiumCaches()
        XCTAssertEqual(policy.chromiumRoots.map { $0.relative }, ["Google/Chrome"])
        XCTAssertEqual(policy.chromiumRoots.first?.profiles, ["Default", "Profile 1"])

        let browser = policy.browserCandidates()
        func label(_ suffix: String) -> String? { browser.first { $0.path.hasSuffix(suffix) }?.label }
        XCTAssertEqual(label("Application Support/Google/Chrome/Default/GPUCache"), "Google Chrome GPU Cache")
        XCTAssertEqual(label("Application Support/Google/Chrome/Profile 1/GPUCache"), "Google Chrome (Profile 1) GPU Cache")
        XCTAssertEqual(label("Application Support/Google/Chrome/ShaderCache"), "Google Chrome Shader Cache")
        XCTAssertEqual(label("Caches/Google/Chrome/Default/Cache"), "Google Chrome Cache")
        XCTAssertEqual(label("Caches/Google/Chrome/Default/Code Cache"), "Google Chrome Code Cache")
        XCTAssertEqual(label("Firefox/Profiles/abc.default/cache2"), "Firefox Cache")
        XCTAssertEqual(label("Caches/com.apple.Safari"), "Safari Cache")
        XCTAssertFalse(browser.contains { $0.path.hasSuffix("Default/Cookies") })
        XCTAssertFalse(browser.contains { $0.path.hasSuffix("Default/Other") })

        let root = policy.rootCandidates()
        let paths = Set(root.map { $0.path })
        XCTAssertTrue(paths.contains("\(lib)/Caches/Google/GoogleUpdater"))
        XCTAssertEqual(root.first { $0.path == "\(lib)/Caches/Google/GoogleUpdater" }?.label, "Google › GoogleUpdater Cache")
        XCTAssertFalse(paths.contains("\(lib)/Caches/Google"), "satıcı klasörü bütün olarak listelenmez")
        XCTAssertFalse(paths.contains("\(lib)/Caches/Google/Chrome"), "Chromium aynası tarayıcı bölümünde ele alınır")
        XCTAssertFalse(paths.contains("\(lib)/Caches/Firefox"))
        XCTAssertFalse(paths.contains("\(lib)/Caches/com.apple.Safari"))
        XCTAssertTrue(paths.contains("\(lib)/Caches/com.apple.Safari.SafeBrowsing"))
        XCTAssertEqual(root.first { $0.path == "\(lib)/Caches/com.apple.helpd" }?.category, .appleService)
        XCTAssertEqual(root.first { $0.path == "\(lib)/Caches/GeoServices" }?.category, .appleService)
        XCTAssertEqual(root.first { $0.path == "\(lib)/Caches/com.apple.dt.Xcode" }?.category, .cache)
        XCTAssertEqual(root.first { $0.path == "\(lib)/Caches/notion.id" }?.category, .cache)
        XCTAssertEqual(root.first { $0.path == "\(lib)/Logs/Notion" }?.category, .log)
        XCTAssertEqual(root.first { $0.path == "\(lib)/Logs/Microsoft/Teams" }?.label, "Microsoft › Teams Logs")
        XCTAssertFalse(paths.contains("\(lib)/Application Support/Notion"))
    }

    func testOperaSingleProfileRoot() throws {
        let lib = home + "/Library"
        let policy = try makePolicy(paths: [
            "\(lib)/Application Support/com.operasoftware.Opera/Cache/data",
            "\(lib)/Application Support/com.operasoftware.Opera/GPUCache/data",
            "\(lib)/Caches/com.operasoftware.Opera/Cache/data",
            "\(lib)/Application Support/Electron/Cache/data"
        ])
        policy.detectChromiumCaches()
        let labels = policy.browserCandidates().map { $0.label ?? "" }
        XCTAssertEqual(labels.sorted(), ["Opera Cache", "Opera Cache", "Opera GPU Cache"])
        XCTAssertFalse(policy.chromiumCachePaths.contains("\(lib)/Application Support/Electron/Cache"))
    }

    func testVerdicts() throws {
        let lib = home + "/Library"
        let policy = try makePolicy(paths: [
            "\(lib)/Application Support/Google/Chrome/Local State",
            "\(lib)/Application Support/Google/Chrome/Default/GPUCache/data",
            "\(lib)/Application Support/Google/Chrome/Default/Cookies"
        ])
        policy.detectChromiumCaches()
        XCTAssertNil(policy.verdict(path: "\(lib)/Caches/notion.id"))
        XCTAssertNil(policy.verdict(path: "\(lib)/Application Support/Google/Chrome/Default/GPUCache"))
        XCTAssertNotNil(policy.verdict(path: "\(lib)/Application Support/Google/Chrome/Default/Cookies"))
        XCTAssertNotNil(policy.verdict(path: "\(lib)/Application Support/Notion"))
        XCTAssertNotNil(policy.verdict(path: "\(lib)/Caches/com.apple.accountsd"))
        XCTAssertNotNil(policy.verdict(path: "\(lib)/Caches/Foo/LoginData"))
        XCTAssertNotNil(policy.verdict(path: "/Library/Caches/x"))
        XCTAssertNotNil(policy.verdict(path: "\(home)/Documents/x"))
        XCTAssertNotNil(policy.verdict(path: home))
        XCTAssertNil(policy.verdict(path: "\(lib)/Containers/com.apple.Safari/Data/Library/Caches/com.apple.Safari"))
    }
}
