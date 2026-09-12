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
