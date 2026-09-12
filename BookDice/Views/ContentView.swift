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
            .navigationTitle("🎲 Book Dice")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.mode == .generator {
                        Button {
                            viewModel.enterConfigMode()
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        .accessibilityLabel("Config Mode")
                    } else {
                        Button("Back to Generator") {
                            viewModel.exitConfigMode()
                        }
                    }
                }
            }
        }
    }
}
