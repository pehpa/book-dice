// Mirrors tests/test_core.py's fixed-seed tests for the pure selection logic.

import XCTest
@testable import BookDiceKit

final class CoreTests: XCTestCase {
    func testPickCategoryRespectsWeightsWithinTolerance() throws {
        let categories = [
            BookCategory(name: "Science Fiction", weight: 50, segments: 4),
            BookCategory(name: "Belletristik", weight: 20, segments: 6),
            BookCategory(name: "Sachbücher", weight: 30, segments: 3),
        ]
        var rng = SeededGenerator(seed: 42)
        var counts: [String: Int] = [:]
        let draws = 20_000
        for _ in 0..<draws {
            let picked = try pickCategory(categories: categories, using: &rng)
            counts[picked.name, default: 0] += 1
        }

        for category in categories {
            let observed = Double(counts[category.name] ?? 0) / Double(draws)
            let expected = category.weight / 100
            XCTAssertEqual(observed, expected, accuracy: 0.02, "category \(category.name)")
        }
    }

    func testPickCategoryThrowsOnEmptyCategories() {
        var rng = SeededGenerator(seed: 1)
        XCTAssertThrowsError(try pickCategory(categories: [], using: &rng)) { error in
            XCTAssertEqual(error as? BookDiceError, .noCategories)
        }
    }

    func testPickCategoryThrowsOnZeroTotalWeight() {
        var rng = SeededGenerator(seed: 1)
        let categories = [BookCategory(name: "Empty", weight: 0, segments: 1)]
        XCTAssertThrowsError(try pickCategory(categories: categories, using: &rng)) { error in
            XCTAssertEqual(error as? BookDiceError, .nonPositiveWeightSum)
        }
    }

    func testPickSegmentBounds() throws {
        var rng = SeededGenerator(seed: 7)
        var seen = Set<Int>()
        for _ in 0..<2_000 {
            let segment = try pickSegment(segments: 4, using: &rng)
            XCTAssertTrue((1...4).contains(segment))
            seen.insert(segment)
        }
        XCTAssertEqual(seen, Set(1...4))
    }

    func testPickSegmentThrowsOnInvalidSegments() {
        var rng = SeededGenerator(seed: 1)
        XCTAssertThrowsError(try pickSegment(segments: 0, using: &rng)) { error in
            XCTAssertEqual(error as? BookDiceError, .invalidSegments)
        }
    }

    func testRollDieBounds() throws {
        var rng = SeededGenerator(seed: 99)
        for _ in 0..<2_000 {
            let roll = try rollDie(faces: 6, using: &rng)
            XCTAssertTrue((1...6).contains(roll))
        }
    }

    func testRollDieThrowsOnInvalidFaces() {
        var rng = SeededGenerator(seed: 1)
        XCTAssertThrowsError(try rollDie(faces: 0, using: &rng)) { error in
            XCTAssertEqual(error as? BookDiceError, .invalidDiceFaces)
        }
    }

    func testSelectShelfReturnsValidResult() throws {
        let config = BookDiceConfig.default
        var rng = SeededGenerator(seed: 5)
        let totalWeight = config.categories.reduce(0) { $0 + $1.weight }

        for _ in 0..<500 {
            let selection = try selectShelf(config: config, using: &rng)
            guard let category = config.categories.first(where: { $0.name == selection.categoryName })
            else {
                XCTFail("unexpected category \(selection.categoryName)")
                continue
            }
            XCTAssertTrue((1...category.segments).contains(selection.segment))
            XCTAssertEqual(selection.segmentsTotal, category.segments)
            XCTAssertEqual(
                selection.weightPercent, (category.weight / totalWeight) * 100, accuracy: 0.0001
            )
        }
    }

    func testSelectShelfThrowsOnEmptyCategories() {
        let config = BookDiceConfig(settings: Settings(), categories: [])
        var rng = SeededGenerator(seed: 1)
        XCTAssertThrowsError(try selectShelf(config: config, using: &rng)) { error in
            XCTAssertEqual(error as? BookDiceError, .noCategories)
        }
    }
}
