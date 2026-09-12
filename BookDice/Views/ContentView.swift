import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            GeneratorView(viewModel: viewModel)
                .background(Color.graphite.ignoresSafeArea())
                // The banner artwork at the top of each screen is the title
                // now, so the nav bar itself stays title-less and compact.
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.enterConfigMode()
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        .accessibilityLabel("Config Mode")
                    }
                }
                // Pushing (rather than swapping content in place) gives the
                // config screen its own navigation bar / large-title state,
                // so scrolling its Form can't leave the generator screen's
                // title minimized when we come back.
                .navigationDestination(
                    isPresented: Binding(
                        get: { viewModel.mode == .config },
                        set: { isPresented in
                            if !isPresented {
                                viewModel.exitConfigMode()
                            }
                        }
                    )
                ) {
                    ConfigView(viewModel: viewModel)
                        .background(Color.graphite.ignoresSafeArea())
                        .navigationTitle("")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Back to Generator") {
                                    viewModel.exitConfigMode()
                                }
                            }
                        }
                }
        }
        .tint(.limeSpark)
        .preferredColorScheme(.dark)
    }
}
