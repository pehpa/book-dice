import SwiftUI

struct GeneratorView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                Button("GENERATE NEXT BOOK") {
                    viewModel.generateNextBook()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)

                Button("Reset") {
                    viewModel.resetGenerator()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .fixedSize()
            }

            resultBox

            if viewModel.shelfSelection != nil {
                rollControls
            }

            dieResultBox

            if let error = viewModel.generatorError {
                Text(error)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Spacer(minLength: 0)
        }
        .padding()
    }

    @ViewBuilder
    private var resultBox: some View {
        VStack(spacing: 8) {
            if let selection = viewModel.shelfSelection {
                Text("Category").font(.caption).foregroundStyle(.secondary)
                Text("\(selection.categoryName) (\(Int(selection.weightPercent.rounded()))%)")
                    .font(.title2).bold()
                Text("Shelf Segment").font(.caption).foregroundStyle(.secondary)
                Text("Section \(selection.segment) of \(selection.segmentsTotal)")
                    .font(.title2).bold()
                Text(
                    "Go to your '\(selection.categoryName)' section, Section \(selection.segment). "
                        + "Pick \(currentDiceFaces) books from that shelf."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            } else {
                Text("Press the button to pick your next shelf.")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var currentDiceFaces: Int {
        viewModel.diceFacesOverride
    }

    private var rollControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Books actually picked (change if it wasn't the default)")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Text("\(viewModel.diceFacesOverride)")
                    .font(.headline)
                    .monospacedDigit()
                    .frame(minWidth: 24)
                Stepper("", value: $viewModel.diceFacesOverride, in: 1...99)
                    .labelsHidden()
                    .fixedSize()
                Button("🎲 Roll the die!") {
                    viewModel.rollDie()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var dieResultBox: some View {
        VStack(spacing: 4) {
            Text("You selected book number")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(viewModel.dieResult.map(String.init) ?? "–")
                .font(.system(size: 48, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
