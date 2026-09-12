import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.mode {
                case .generator:
                    GeneratorView(viewModel: viewModel)
                case .config:
                    ConfigView(viewModel: viewModel)
                }
            }
            .navigationTitle("🎲 book-dice")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.mode == .generator ? "Config Mode" : "Back to Generator") {
                        if viewModel.mode == .generator {
                            viewModel.enterConfigMode()
                        } else {
                            viewModel.exitConfigMode()
                        }
                    }
                }
            }
        }
    }
}
