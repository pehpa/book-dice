import SwiftUI
import BookDiceKit

struct ConfigView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Default dice faces (books per shelf)")
                    Spacer()
                    TextField("6", text: $viewModel.draftDefaultDiceFaces)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
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
                        .foregroundStyle(message.isError ? .red : .green)
                }
            }
        }
    }
}
