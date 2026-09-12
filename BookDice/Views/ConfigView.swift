import SwiftUI
import BookDiceKit

struct ConfigView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ZStack(alignment: .top) {
            Form {
                Section {
                    HStack {
                        Text("Default die faces").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Stepper(
                            "\(viewModel.draftDefaultDiceFaces)",
                            value: $viewModel.draftDefaultDiceFaces,
                            in: 1...99
                        )
                        .fixedSize()
                    }
                }

                Section("Categories") {
                    ForEach($viewModel.draftCategories) { $category in
                        CategoryRowView(category: $category) {
                            viewModel.removeCategory(category)
                        }
                    }
                    Button("+ Add Category") {
                        viewModel.addCategory()
                    }
                }

                Section {
                    Button("Save Configuration") {
                        viewModel.saveConfiguration()
                    }
                    .frame(maxWidth: .infinity)
                    if let message = viewModel.configMessage {
                        Text(message.text)
                            .foregroundStyle(.red)
                    }
                }
            }

            VStack(spacing: 8) {
                ForEach(viewModel.toasts) { toast in
                    Text(toast.text)
                        .font(.footnote)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(toast.style.backgroundColor, in: Capsule())
                        .shadow(radius: 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.top, 8)
            .zIndex(1)
        }
        .animation(.easeInOut, value: viewModel.toasts)
    }
}

private extension ConfigToast.Style {
    /// Warning (normalization) reads as a slightly yellowish orange;
    /// success (configuration saved) reads as green.
    var backgroundColor: Color {
        switch self {
        case .success:
            return Color.green.opacity(0.85)
        case .warning:
            return Color.orange.opacity(0.85)
        }
    }
}
