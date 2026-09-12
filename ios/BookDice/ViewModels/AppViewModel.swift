// Orchestrates the two-phase selection flow and config editing — the SwiftUI
// analogue of book_dice/cli.py's interactive loop / web.py's two endpoints.

import Foundation
import BookDiceKit

@MainActor
final class AppViewModel: ObservableObject {
    enum Mode {
        case generator
        case config
    }

    @Published var mode: Mode = .generator
    @Published private(set) var config: BookDiceConfig

    // Generator screen state
    @Published var shelfSelection: ShelfSelection?
    @Published var dieResult: Int?
    @Published var diceFacesOverrideText: String = ""
    @Published var generatorError: String?

    // Config screen state (a working copy, mirroring index.html's categoryRows)
    @Published var draftDefaultDiceFaces: String = ""
    @Published var draftCategories: [BookCategory] = []
    @Published var configMessage: (text: String, isError: Bool)?

    private let store: ConfigStore

    init(store: ConfigStore = .defaultStore()) {
        self.store = store
        self.config = (try? store.load()) ?? .default
    }

    // MARK: - Generator

    func generateNextBook() {
        generatorError = nil
        dieResult = nil
        do {
            let selection = try selectShelf(config: config)
            shelfSelection = selection
            diceFacesOverrideText = String(config.settings.defaultDiceFaces)
        } catch {
            shelfSelection = nil
            generatorError = error.localizedDescription
        }
    }

    func rollDie() {
        generatorError = nil
        guard let diceFaces = Int(diceFacesOverrideText), diceFaces >= 1 else {
            generatorError = "Books picked must be a whole number of at least 1."
            return
        }
        do {
            dieResult = try BookDiceKit.rollDie(faces: diceFaces)
        } catch {
            generatorError = error.localizedDescription
        }
    }

    // MARK: - Config

    func enterConfigMode() {
        config = (try? store.load()) ?? config
        draftDefaultDiceFaces = String(config.settings.defaultDiceFaces)
        draftCategories = config.categories
        configMessage = nil
        mode = .config
    }

    func exitConfigMode() {
        mode = .generator
    }

    func addCategory() {
        draftCategories.append(BookCategory(name: "", weight: 10, segments: 1))
    }

    func removeCategory(_ category: BookCategory) {
        draftCategories.removeAll { $0.id == category.id }
    }

    func saveConfiguration() {
        if let validationError = validateCategories(draftCategories) {
            configMessage = (validationError.localizedDescription ?? "Invalid configuration.", true)
            return
        }
        guard let defaultDiceFaces = Int(draftDefaultDiceFaces), defaultDiceFaces >= 1 else {
            configMessage = ("Default dice faces must be a whole number of at least 1.", true)
            return
        }

        var newConfig = config
        newConfig.settings.defaultDiceFaces = defaultDiceFaces
        newConfig.categories = draftCategories

        do {
            try store.save(newConfig)
            config = newConfig
            configMessage = ("Configuration saved.", false)
        } catch {
            configMessage = ("Save failed: \(error.localizedDescription)", true)
        }
    }
}
