// Pure selection logic, mirroring book_dice/core.py: weighted category,
// uniform segment, and die roll. No I/O — everything takes an explicit RNG,
// which is what makes it testable with fixed seeds (see RandomSource.swift).

import Foundation

public enum BookDiceError: Error, LocalizedError, Equatable {
    case noCategories
    case nonPositiveWeightSum
    case invalidSegments
    case invalidDiceFaces

    public var errorDescription: String? {
        switch self {
        case .noCategories:
            return "no categories configured"
        case .nonPositiveWeightSum:
            return "category weights must sum to a positive number"
        case .invalidSegments:
            return "segments must be at least 1"
        case .invalidDiceFaces:
            return "dice faces must be at least 1"
        }
    }
}

public func pickCategory(
    categories: [BookCategory],
    using rng: inout some RandomNumberGenerator
) throws -> BookCategory {
    guard !categories.isEmpty else { throw BookDiceError.noCategories }
    let totalWeight = categories.reduce(0) { $0 + $1.weight }
    guard totalWeight > 0 else { throw BookDiceError.nonPositiveWeightSum }

    let threshold = Double.random(in: 0..<totalWeight, using: &rng)
    var cumulative = 0.0
    for category in categories {
        cumulative += category.weight
        if threshold < cumulative {
            return category
        }
    }
    // Floating-point rounding can leave threshold just shy of totalWeight
    // without tripping any comparison above; fall back to the last category.
    return categories[categories.count - 1]
}

public func pickSegment(segments: Int, using rng: inout some RandomNumberGenerator) throws -> Int {
    guard segments >= 1 else { throw BookDiceError.invalidSegments }
    return Int.random(in: 1...segments, using: &rng)
}

public func rollDie(faces: Int, using rng: inout some RandomNumberGenerator) throws -> Int {
    guard faces >= 1 else { throw BookDiceError.invalidDiceFaces }
    return Int.random(in: 1...faces, using: &rng)
}

public struct ShelfSelection: Equatable, Sendable {
    public let categoryName: String
    public let weightPercent: Double
    public let segment: Int
    public let segmentsTotal: Int
}

public func selectShelf(
    config: BookDiceConfig,
    using rng: inout some RandomNumberGenerator
) throws -> ShelfSelection {
    let category = try pickCategory(categories: config.categories, using: &rng)
    let totalWeight = config.categories.reduce(0) { $0 + $1.weight }
    let weightPercent = (category.weight / totalWeight) * 100

    let segment = try pickSegment(segments: category.segments, using: &rng)

    return ShelfSelection(
        categoryName: category.name,
        weightPercent: weightPercent,
        segment: segment,
        segmentsTotal: category.segments
    )
}

// MARK: - Convenience overloads using the system RNG

public func pickCategory(categories: [BookCategory]) throws -> BookCategory {
    var rng = SystemRandomNumberGenerator()
    return try pickCategory(categories: categories, using: &rng)
}

public func pickSegment(segments: Int) throws -> Int {
    var rng = SystemRandomNumberGenerator()
    return try pickSegment(segments: segments, using: &rng)
}

public func rollDie(faces: Int) throws -> Int {
    var rng = SystemRandomNumberGenerator()
    return try rollDie(faces: faces, using: &rng)
}

public func selectShelf(config: BookDiceConfig) throws -> ShelfSelection {
    var rng = SystemRandomNumberGenerator()
    return try selectShelf(config: config, using: &rng)
}
