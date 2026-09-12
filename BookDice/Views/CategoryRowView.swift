import SwiftUI
import BookDiceKit

struct CategoryRowView: View {
    @Binding var category: BookCategory
    var onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Category name", text: $category.name)
                    .textFieldStyle(.roundedBorder)
                Button {
                    onRemove()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.borderless)
            }
            HStack {
                Text("Weight").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Stepper(
                    "\(Int(category.weight))%",
                    value: $category.weight,
                    in: 0...100,
                    step: 1
                )
                .fixedSize()
            }
            HStack {
                Text("Shelf sections").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Stepper(
                    "\(category.segments)",
                    value: $category.segments,
                    in: 1...99
                )
                .fixedSize()
            }
        }
        .padding(.vertical, 4)
    }
}
