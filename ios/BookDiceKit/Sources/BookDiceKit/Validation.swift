// Config-editing validation, mirroring static/index.html's saveConfig() JS:
// kept here (not inline in a view/view model) so it's unit-testable without SwiftUI.

import Foundation

public enum ConfigValidationError: Error, LocalizedError, Equatable {
    case invalidCategoryFields
    case weightsDontSumTo100(total: Double)

    public var errorDescription: String? {
        switch self {
        case .invalidCategoryFields:
            return "Each category needs a name, a weight ≥ 0, and at least 1 segment."
        case .weightsDontSumTo100(let total):
            return "Weights must sum to 100 (currently \(Int(total)))."
        }
    }
}

/// Returns the validation error for these categories, or nil if they're valid.
public func validateCategories(_ categories: [BookCategory]) -> ConfigValidationError? {
    let hasInvalidRow = categories.contains { category in
        category.name.trimmingCharacters(in: .whitespaces).isEmpty
            || category.weight < 0
            || category.segments < 1
    }
    if hasInvalidRow {
        return .invalidCategoryFields
    }

    let totalWeight = categories.reduce(0) { $0 + $1.weight }
    if !categories.isEmpty && totalWeight != 100 {
        return .weightsDontSumTo100(total: totalWeight)
    }

    return nil
}
