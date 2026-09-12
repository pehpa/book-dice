// Brand palette: dark graphite background with a lime accent, matching the
// app icon (a lime die on a graphite background). Backed by color assets in
// Assets.xcassets so both code and the asset catalog share one source of
// truth for the actual RGB values.

import SwiftUI

extension Color {
    /// Page background — Graphite, #23262F.
    static let graphite = Color("Graphite")
    /// Elevated surfaces (cards/panels) — a lighter graphite for contrast
    /// against the page background.
    static let graphiteSurface = Color("GraphiteSurface")
    /// Primary accent — Lime Spark, #B6FF2E. Matches AccentColor, spelled
    /// out for call sites that want the brand color explicitly (e.g. to
    /// pair it with a specific foreground color for contrast).
    static let limeSpark = Color("LimeSpark")
}

/// Shared layout constants so the two screens' headers line up identically.
enum Metrics {
    /// Gap between the nav bar and the title mark — kept tight.
    static let titleTopPadding: CGFloat = 4
    /// Gap between the title mark and each screen's own content below —
    /// kept generous so the title reads as its own element.
    static let titleBottomPadding: CGFloat = 28
}
