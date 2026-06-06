import HealthKit
import LoopAlgorithm
import LoopKitUI
import SwiftUI

struct CalibrationView: View {
    @EnvironmentObject private var displayGlucosePreference: DisplayGlucosePreference
    @ObservedObject var viewModel: CalibrationViewModel

    @State var isEdittingGlucose = false

    var isMgDl: Bool {
        displayGlucosePreference.unit == .milligramsPerDeciliter
    }

    var body: some View {
        VStack {
            List {
                Section {
                    DatePicker(
                        String(localized: "Time", comment: "label time"),
                        selection: $viewModel.time,
                        displayedComponents: .hourAndMinute
                    )

                    Button(action: { withAnimation { isEdittingGlucose.toggle() } }) {
                        HStack(alignment: .bottom) {
                            Text("Glucose level", comment: "label glucose")
                                .foregroundColor(isEdittingGlucose ? .blue : .primary)
                            Spacer()
                            Text(formatGlucose(viewModel.glucose))
                                .foregroundColor(isEdittingGlucose ? .blue : .secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    if isEdittingGlucose {
                        ResizeablePicker(
                            selection: $viewModel.glucose,
                            data: isMgDl ? viewModel.allowedGlucoseValuesMgDl : viewModel.allowedGlucoseValuesMmolL,
                            formatter: { formatGlucose($0) }
                        )
                        .padding(.horizontal)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())

            Spacer()
            if !viewModel.error.isEmpty {
                Text(viewModel.error)
                    .foregroundStyle(.red)
            }
            Button(action: viewModel.calibrate) {
                Text("Calibrate transmitter", comment: "calibration")
            }
            .buttonStyle(ActionButtonStyle())
            .padding([.bottom, .horizontal])
            .disabled(!viewModel.allowCalibrations || viewModel.isLoading)
        }
        .navigationTitle(String(localized: "Calibration", comment: "Calibation header"))
    }

    private func formatGlucose(_ value: UInt16) -> String {
        let quantity = LoopQuantity(
            unit: isMgDl ? .milligramsPerDeciliter : .millimolesPerLiter,
            doubleValue: isMgDl ? Double(value) : Double(value) / 10
        )
        return displayGlucosePreference.format(quantity)
    }
}
