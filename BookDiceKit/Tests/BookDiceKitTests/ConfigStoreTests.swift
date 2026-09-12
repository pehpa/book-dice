import XCTest
@testable import BookDiceKit

final class ConfigStoreTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUpWithError() throws {
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDirectory)
    }

    func testLoadSeedsDefaultConfigOnFirstRun() throws {
        let store = ConfigStore(directory: tempDirectory)
        let config = try store.load()
        XCTAssertEqual(config, .default)

        let fileURL = tempDirectory.appendingPathComponent("config.json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
    }

    func testSaveThenLoadRoundTrips() throws {
        let store = ConfigStore(directory: tempDirectory)
        var config = BookDiceConfig.default
        config.settings.defaultDiceFaces = 8
        config.categories.append(BookCategory(name: "Poetry", weight: 0, segments: 2))

        try store.save(config)
        let reloaded = try store.load()
        XCTAssertEqual(reloaded, config)
    }

    func testLoadThrowsOnMalformedJSON() throws {
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        let fileURL = tempDirectory.appendingPathComponent("config.json")
        try Data("not json".utf8).write(to: fileURL)

        let store = ConfigStore(directory: tempDirectory)
        XCTAssertThrowsError(try store.load()) { error in
            guard case ConfigStoreError.malformedJSON = error else {
                return XCTFail("expected malformedJSON, got \(error)")
            }
        }
    }
}
