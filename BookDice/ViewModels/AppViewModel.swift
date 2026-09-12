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
    @Published var diceFacesOverride: Int = 6
    @Published var generatorError: String?

    // Config screen state (a working copy, mirroring index.html's categoryRows)
    @Published var draftDefaultDiceFaces: Int = 6
    @Published var draftCategories: [BookCategory] = []
    @Published var configMessage: (text: String, isError: Bool)?
    @Published private(set) var toasts: [ConfigToast] = []

    private let store: ConfigStore

    init(store: ConfigStore = .defaultStore()) {
        self.store = store
        let loaded = (try? store.load()) ?? .default
        self.config = loaded
        self.diceFacesOverride = loaded.settings.defaultDiceFaces
    }

    // MARK: - Generator

    func generateNextBook() {
        generatorError = nil
        dieResult = nil
        do {
            let selection = try selectShelf(config: config)
            shelfSelection = selection
            diceFacesOverride = config.settings.defaultDiceFaces
        } catch {
            shelfSelection = nil
            generatorError = error.localizedDescription
        }
    }

    func rollDie() {
        generatorError = nil
        do {
            dieResult = try BookDiceKit.rollDie(faces: diceFacesOverride)
        } catch {
            generatorError = error.localizedDescription
        }
    }

    /// Restores the generator screen to the state it's in right after launch.
    func resetGenerator() {
        shelfSelection = nil
        dieResult = nil
        generatorError = nil
        diceFacesOverride = config.settings.defaultDiceFaces
    }

    // MARK: - Config

    func enterConfigMode() {
        config = (try? store.load()) ?? config
        draftDefaultDiceFaces = config.settings.defaultDiceFaces
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

        let normalized = normalizedCategories(draftCategories)
        let didNormalize = normalized != draftCategories
        draftCategories = normalized

        var newConfig = config
        newConfig.settings.defaultDiceFaces = draftDefaultDiceFaces
        newConfig.categories = normalized

        do {
            try store.save(newConfig)
            config = newConfig
            configMessage = nil
            showToast("Configuration saved.", style: .success)
            if didNormalize {
                showToast("Weights didn't add up to 100% — normalized automatically.", style: .warning)
            }
        } catch {
            configMessage = ("Save failed: \(error.localizedDescription)", true)
        }
    }

    private func showToast(_ text: String, style: ConfigToast.Style) {
        let toast = ConfigToast(text: text, style: style)
        toasts.append(toast)
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(2.5))
            self?.toasts.removeAll { $0.id == toast.id }
        }
    }
}

/// A transient overlay pop-up shown over the config form, color-coded by kind
/// (e.g. a green "saved" confirmation vs. an orange normalization warning).
struct ConfigToast: Identifiable, Equatable {
    enum Style: Equatable {
        case success
        case warning
    }

    let id = UUID()
    let text: String
    let style: Style
}
