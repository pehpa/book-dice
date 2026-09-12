// Config-editing validation and normalization, mirroring (and, for the weight
// sum, deliberately diverging from) static/index.html's saveConfig() JS: kept
// here (not inline in a view/view model) so it's unit-testable without SwiftUI.

import Foundation

public enum ConfigValidationError: Error, LocalizedError, Equatable {
    case invalidCategoryFields
    case nonPositiveWeightSum

    public var errorDescription: String? {
        switch self {
        case .invalidCategoryFields:
            return "Each category needs a name, a weight ≥ 0, and at least 1 segment."
        case .nonPositiveWeightSum:
            return "At least one category needs a weight greater than 0."
        }
    }
}

/// Returns the validation error for these categories, or nil if they're valid.
/// A weight sum other than 100 is not an error here — the caller normalizes
/// it instead (see `normalizedCategories`).
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
    if !categories.isEmpty && totalWeight <= 0 {
        return .nonPositiveWeightSum
    }

    return nil
}

/// Proportionally rescales weights so they sum to exactly 100, rounding to
/// whole percents and correcting rounding drift (via largest-remainder
/// apportionment) so the total lands exactly on 100. Categories that are
/// already valid (see `validateCategories`) and already sum to 100 come back
/// unchanged. Defensive no-op if weights can't be normalized (empty list, or
/// a non-positive total — callers should have already rejected that case).
public func normalizedCategories(_ categories: [BookCategory]) -> [BookCategory] {
    guard !categories.isEmpty else { return categories }

    let totalWeight = categories.reduce(0) { $0 + $1.weight }
    guard totalWeight > 0 else { return categories }
    guard totalWeight != 100 else { return categories }

    let scaled = categories.map { $0.weight * 100 / totalWeight }
    var floored = scaled.map { $0.rounded(.down) }
    let remainders = zip(scaled, floored).map { $0 - $1 }

    var deficit = Int(100 - floored.reduce(0, +))
    let orderedByRemainder = remainders.indices.sorted { remainders[$0] > remainders[$1] }
    for index in orderedByRemainder where deficit > 0 {
        floored[index] += 1
        deficit -= 1
    }

    return zip(categories, floored).map { category, weight in
        var updated = category
        updated.weight = weight
        return updated
    }
}
