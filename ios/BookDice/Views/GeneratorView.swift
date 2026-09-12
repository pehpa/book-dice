import SwiftUI

struct GeneratorView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Button("GENERATE NEXT BOOK") {
                    viewModel.generateNextBook()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)

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
            }
            .padding()
        }
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
        Int(viewModel.diceFacesOverrideText) ?? viewModel.config.settings.defaultDiceFaces
    }

    private var rollControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Books actually picked (change if it wasn't the default)")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                TextField("Books picked", text: $viewModel.diceFacesOverrideText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
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
