# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Regenerate BookDice.xcodeproj from project.yml (after adding/removing files or targets)
xcodegen generate

# Run BookDiceKit's test suite (no Xcode needed)
cd BookDiceKit
swift test

# Run a single test
swift test --filter CoreTests/testPickCategoryRespectsWeights

# Build/run the app: open BookDice.xcodeproj in Xcode and use the Simulator or a
# connected device, or:
xcodebuild -project BookDice.xcodeproj -scheme BookDice build
```

## Architecture

Two parts, wired together via `project.yml` (an [XcodeGen](https://github.com/yonaskolb/XcodeGen) spec) into `BookDice.xcodeproj`, which is checked in and regenerated from `project.yml` rather than hand-edited.

- `BookDiceKit/` — a Swift package (`Package.swift`) with the pure, testable logic. No SwiftUI/UIKit dependency.
  - `Core.swift` — pure selection logic: `pickCategory` (weighted), `pickSegment` (uniform), `rollDie`, and `selectShelf` (combines the first two into a `ShelfSelection`). Takes an injectable RNG (`RandomSource.swift`), which is what makes it testable with fixed seeds.
  - `Models.swift` — `Settings`/`BookCategory`/`BookDiceConfig`, the config schema (category name → weight/segments, plus default dice-face count).
  - `ConfigStore.swift` — loads/creates/persists the config on-device (Application Support), analogous to load/save with defaults on first run.
  - `Validation.swift` — category-weight handling for saves; normalizes weights that don't sum to 100% rather than rejecting the save.
  - Tests live in `Tests/BookDiceKitTests/` (`CoreTests.swift`, `ConfigStoreTests.swift`, `ValidationTests.swift`).
- `BookDice/` — the SwiftUI app target.
  - `BookDiceApp.swift` — app entry point.
  - `ViewModels/AppViewModel.swift` — drives the same two-phase flow as the underlying logic: pick a shelf/category, then roll once the user confirms how many books they gathered.
  - `Views/` — `ContentView.swift` (top-level), `GeneratorView.swift` (the roll flow), `ConfigView.swift` + `CategoryRowView.swift` (editing categories/weights/segments).
  - `Assets.xcassets/` — app icon and asset catalog.
