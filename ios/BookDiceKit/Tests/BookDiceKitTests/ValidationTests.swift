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

    func testWeightsNotSummingTo100() {
        let categories = [BookCategory(name: "A", weight: 50, segments: 1)]
        XCTAssertEqual(validateCategories(categories), .weightsDontSumTo100(total: 50))
    }
}
