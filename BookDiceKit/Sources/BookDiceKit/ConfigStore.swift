// Configuration persistence, mirroring book_dice/config.py's load_config/save_config:
// seeds and persists BookDiceConfig.default on first run, otherwise reads/writes
// JSON. Takes an injectable directory so tests can point it at a temp dir
// instead of the real app sandbox.

import Foundation

public enum ConfigStoreError: Error, LocalizedError, Equatable {
    case malformedJSON(String)

    public var errorDescription: String? {
        switch self {
        case .malformedJSON(let detail):
            return "config.json is not valid JSON: \(detail)"
        }
    }
}

public final class ConfigStore {
    private let fileURL: URL
    private let fileManager: FileManager

    public init(directory: URL, fileManager: FileManager = .default) {
        self.fileURL = directory.appendingPathComponent("config.json")
        self.fileManager = fileManager
    }

    /// The on-device location used by the app: Application Support/BookDice/config.json.
    /// Application Support (not Documents) since this is app-managed config, not
    /// something the user should browse via the Files app.
    public static func defaultStore() -> ConfigStore {
        let base = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        )[0]
        let directory = base.appendingPathComponent("BookDice", isDirectory: true)
        return ConfigStore(directory: directory)
    }

    public func load() throws -> BookDiceConfig {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            try save(.default)
            return .default
        }
        let data = try Data(contentsOf: fileURL)
        do {
            return try JSONDecoder().decode(BookDiceConfig.self, from: data)
        } catch {
            throw ConfigStoreError.malformedJSON(error.localizedDescription)
        }
    }

    public func save(_ config: BookDiceConfig) throws {
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let data = try encoder.encode(config)
        try data.write(to: fileURL, options: .atomic)
    }
}
