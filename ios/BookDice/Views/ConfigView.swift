import SwiftUI
import BookDiceKit

struct ConfigView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ZStack(alignment: .top) {
            Form {
                Section {
                    Stepper(
                        "Default dice faces: \(viewModel.draftDefaultDiceFaces)",
                        value: $viewModel.draftDefaultDiceFaces,
                        in: 1...99
                    )
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
                            .foregroundStyle(message.isError ? .red : .green)
                    }
                }
            }

            if let notice = viewModel.normalizationNotice {
                Text(notice)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.thinMaterial, in: Capsule())
                    .shadow(radius: 4)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: viewModel.normalizationNotice)
    }
}
