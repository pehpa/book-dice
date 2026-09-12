import XCTest
@testable import BookDiceKit

final class ValidationTests: XCTestCase {
    func testEmptyCategoriesAreValid() {
        XCTAssertNil(validateCategories([]))
    }

    func testValidCategoriesSummingTo100() {
        let categories = [
            BookCategory(name: "A", weight: 60, segments: 1),
            BookCategory(name: "B", weight: 40, segments: 2),
        ]
        XCTAssertNil(validateCategories(categories))
    }

    func testBlankNameIsInvalid() {
        let categories = [BookCategory(name: "  ", weight: 100, segments: 1)]
        XCTAssertEqual(validateCategories(categories), .invalidCategoryFields)
    }

    func testNegativeWeightIsInvalid() {
        let categories = [BookCategory(name: "A", weight: -1, segments: 1)]
        XCTAssertEqual(validateCategories(categories), .invalidCategoryFields)
    }

    func testZeroSegmentsIsInvalid() {
        let categories = [BookCategory(name: "A", weight: 100, segments: 0)]
        XCTAssertEqual(validateCategories(categories), .invalidCategoryFields)
    }

    func testWeightsNotSummingTo100IsStillValid() {
        // A sum other than 100 is no longer a validation error — it gets
        // normalized on save instead (see normalizedCategories tests below).
        let categories = [BookCategory(name: "A", weight: 50, segments: 1)]
        XCTAssertNil(validateCategories(categories))
    }

    func testAllZeroWeightsIsInvalid() {
        let categories = [
            BookCategory(name: "A", weight: 0, segments: 1),
            BookCategory(name: "B", weight: 0, segments: 1),
        ]
        XCTAssertEqual(validateCategories(categories), .nonPositiveWeightSum)
    }

    func testNormalizeEmptyCategoriesIsANoOp() {
        XCTAssertEqual(normalizedCategories([]), [])
    }

    func testNormalizeAlreadySummingTo100IsUnchanged() {
        let categories = [
            BookCategory(name: "A", weight: 60, segments: 1),
            BookCategory(name: "B", weight: 40, segments: 2),
        ]
        XCTAssertEqual(normalizedCategories(categories), categories)
    }

    func testNormalizeRescalesToSumExactly100() {
        let categories = [
            BookCategory(name: "A", weight: 1, segments: 1),
            BookCategory(name: "B", weight: 1, segments: 1),
            BookCategory(name: "C", weight: 1, segments: 1),
        ]
        let normalized = normalizedCategories(categories)
        XCTAssertEqual(normalized.reduce(0) { $0 + $1.weight }, 100)
        // Roughly even split, off by at most 1 due to rounding.
        for category in normalized {
            XCTAssertEqual(category.weight, 100.0 / 3.0, accuracy: 1)
        }
    }

    func testNormalizeSkewedWeights() {
        let categories = [
            BookCategory(name: "A", weight: 50, segments: 1),
            BookCategory(name: "B", weight: 150, segments: 1),
        ]
        let normalized = normalizedCategories(categories)
        XCTAssertEqual(normalized.reduce(0) { $0 + $1.weight }, 100)
        XCTAssertEqual(normalized[0].weight, 25)
        XCTAssertEqual(normalized[1].weight, 75)
    }

    func testNormalizeAllZeroWeightsIsANoOp() {
        // Defensive only — validateCategories should reject this before it
        // ever reaches normalizedCategories.
        let categories = [
            BookCategory(name: "A", weight: 0, segments: 1),
            BookCategory(name: "B", weight: 0, segments: 1),
        ]
        XCTAssertEqual(normalizedCategories(categories), categories)
    }
}
