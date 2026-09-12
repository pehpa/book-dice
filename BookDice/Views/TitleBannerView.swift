import SwiftUI

/// The app mark shown atop both screens, replacing the plain text nav bar
/// title: the icon glyph and "Book Dice" wordmark side by side, both
/// transparent-background cutouts (just the glowing line art/letters,
/// background art discarded) so they blend directly into the graphite page
/// background with no card or seam.
struct TitleBannerView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            Image("AppMark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)

            Image("TitleBanner")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 62)
                // The wordmark's visual weight (serif cap-height letters)
                // sits slightly lower within a tight crop than the icon's
                // solid shape does within its own — nudge it up to true
                // optical center against the icon.
                .offset(y: -5.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Book Dice")
    }
}
