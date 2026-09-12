// Configuration data model, mirroring book_dice/config.py's pydantic models.

import Foundation

public struct Settings: Codable, Equatable, Sendable {
    public var defaultDiceFaces: Int

    public init(defaultDiceFaces: Int = 6) {
        self.defaultDiceFaces = defaultDiceFaces
    }
}

public struct BookCategory: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var weight: Double
    public var segments: Int

    public init(id: UUID = UUID(), name: String, weight: Double, segments: Int) {
        self.id = id
        self.name = name
        self.weight = weight
        self.segments = segments
    }
}

public struct BookDiceConfig: Codable, Equatable, Sendable {
    public var settings: Settings
    public var categories: [BookCategory]

    public init(settings: Settings = Settings(), categories: [BookCategory] = []) {
        self.settings = settings
        self.categories = categories
    }

    /// Seeded on first run, mirroring config.py's DEFAULT_CONFIG.
    public static let `default` = BookDiceConfig(
        settings: Settings(defaultDiceFaces: 6),
        categories: [
            BookCategory(name: "Science Fiction", weight: 50, segments: 4),
            BookCategory(name: "Belletristik", weight: 20, segments: 6),
            BookCategory(name: "Sachbücher", weight: 30, segments: 3),
        ]
    )
}
