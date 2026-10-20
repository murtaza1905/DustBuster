import XCTest
@testable import DustBusterCore

/// Tests/DustBusterCoreTests/Fixtures altındaki her vaka sanal diskte çalıştırılır ve beklentiyle karşılaştırılır.
/// Yeni bir vaka eklemek için JSON dosyasını klasöre koymak yeterlidir; kod değişmez.
final class FixtureTests: XCTestCase {
    static let database = CaskDatabase.bundled()

    private func fixtureURLs() throws -> [URL] {
        guard let dir = Bundle.module.url(forResource: "Fixtures", withExtension: nil) else {
            XCTFail("Fixtures klasörü pakete gömülmemiş")
            return []
        }
        let urls = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        return urls.filter { $0.pathExtension == "json" }.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    func testBundledDatabaseLoads() throws {
        let db = try XCTUnwrap(Self.database, "cask-zap.json yüklenemedi")
        XCTAssertGreaterThan(db.count, 4000, "veritabanı beklenenden küçük: \(db.count)")
        let chrome = AppIdentity(name: "Google Chrome", bundleId: "com.google.Chrome", appPath: "/Applications/Google Chrome.app")
        XCTAssertEqual(db.lookup(identity: chrome).map { $0.token }, ["google-chrome"])
    }

    func testAllFixtures() throws {
        let urls = try fixtureURLs()
        XCTAssertFalse(urls.isEmpty, "hiç vaka yok")
        var failures: [String] = []
        for url in urls {
            let fixture = try Fixture.load(from: Data(contentsOf: url))
            let (result, verdict) = fixture.run(caskDatabase: Self.database)
            if !verdict.passed {
                failures.append("── \(url.lastPathComponent) — \(fixture.name)\n\(verdict.summary)")
            } else if !verdict.unexpectedExtras.isEmpty {
                // Bilgi amaçlı: beklentiye yazılmamış ek bulgular
                print("ℹ️ \(url.lastPathComponent): \(verdict.unexpectedExtras.joined(separator: "; "))")
            }
            XCTAssertLessThanOrEqual(result.droppedDeepCount, 0, "\(url.lastPathComponent): güvenlik sınırı aşıldı (\(result.droppedDeepCount))")
        }
        if !failures.isEmpty {
            XCTFail("\(failures.count) vaka başarısız:\n" + failures.joined(separator: "\n"))
        }
    }

    func testFixturesRoundTripThroughJSON() throws {
        for url in try fixtureURLs() {
            let fixture = try Fixture.load(from: Data(contentsOf: url))
            let again = try Fixture.load(from: fixture.jsonData())
            XCTAssertEqual(fixture, again, url.lastPathComponent)
        }
    }
}
