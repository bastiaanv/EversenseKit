import LoopKitUI
import SwiftUI

struct EversenseSettingsView: View {
    @Environment(\.dismissAction) private var dismiss
    @Environment(\.guidanceColors) private var guidanceColors
    @EnvironmentObject private var displayGlucosePreference: DisplayGlucosePreference

    @ObservedObject var viewModel: EversenseSettingsViewModel

    var removeCgmManagerActionSheet: ActionSheet {
        ActionSheet(
            title: Text(LocalizedString("Remove CGM", comment: "Label for CgmManager deletion button")),
            message: Text(LocalizedString(
                "Are you sure you want to stop using Eversense CGM?",
                comment: "Message for CgmManager deletion action sheet"
            )),
            buttons: [
                .destructive(
                    Text(LocalizedString("Confirm", comment: "Confirmation label"))
                ) {
                    viewModel.deleteCgm()
                },
                .cancel()
            ]
        )
    }

    var body: some View {
        List {
            Section {
                VStack {
                    HStack {
                        Spacer()
                        Image(uiImage: UIImage(
                            named: "transmitter",
                            in: Bundle(for: EversenseUIController.self),
                            compatibleWith: nil
                        )!)
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal)
                            .frame(height: 150)
                        Spacer()
                    }

                    HStack(alignment: .bottom) {
                        Text(LocalizedString("Next calibration in", comment: "Calibration hint"))
                            .foregroundColor(.secondary)
                        Spacer()
                        calibarationTimer
                    }

                    ProgressView(value: viewModel.nextCalibrationProcess)
                        .scaleEffect(x: 1, y: 4, anchor: .center)
                        .padding(.top, 2)
                }

                HStack(alignment: .top) {
                    transmitterState
                    Spacer()
                    transmitterSerial
                }
                .padding(.bottom, 5)
            }

            Section(header: SectionHeader(label: LocalizedString(
                "Recent glucose",
                comment: "last reading"
            ))) {
                SectionItem(
                    title: LocalizedString("Glucose", comment: "last reading"),
                    value: displayGlucosePreference.format(viewModel.lastMeasurement)
                )
                SectionItem(
                    title: LocalizedString("Time", comment: "last reading"),
                    value: viewModel.lastMeasurementDatetime
                )
            }

            Section(header: SectionHeader(label: LocalizedString(
                "Calibrations",
                comment: "last reading"
            ))) {
                SectionItem(
                    title: LocalizedString("Last calibration time", comment: "last calibration"),
                    value: viewModel.lastCalibrationDatetime
                )
                SectionItem(
                    title: LocalizedString("Next calibration time", comment: "next calibration"),
                    value: viewModel.nextCalibrationDatetime
                )
            }

            Section(header: SectionHeader(label: LocalizedString(
                "Transmitter information",
                comment: "last reading"
            ))) {
                SectionItem(
                    title: LocalizedString("Current phase", comment: "current phase"),
                    value: viewModel.currentPhase
                )
                SectionItem(
                    title: LocalizedString("Signal strength", comment: "transmitter implant signal strength"),
                    value: viewModel.signalStrength
                )
                NavigationLink(destination: TransmitterSettingsView(viewModel: viewModel.transmitterSettingsViewModel)) {
                    Text(LocalizedString("Transmitter settings", comment: "go to transmitter settings"))
                }
            }

            Section {
                Button(action: viewModel.readGlucose) {
                    Text(LocalizedString("Force sync", comment: "TEMP"))
                }
                Button(action: {
                    viewModel.showingDeleteConfirmation = true
                }) {
                    Text(LocalizedString("Delete CGM", comment: "Label for CgmManager deletion button"))
                        .foregroundColor(guidanceColors.critical)
                }
                .actionSheet(isPresented: $viewModel.showingDeleteConfirmation) {
                    removeCgmManagerActionSheet
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarItems(trailing: Button(LocalizedString("Done", comment: "done button title"), action: dismiss))
        .navigationBarTitle(viewModel.transmitterModel)
    }

    @ViewBuilder private var transmitterState: some View {
        VStack(alignment: .leading) {
            Text(LocalizedString("State", comment: "Transmitter state"))
                .fontWeight(.heavy)
                .fixedSize()
            Text(viewModel.connectionStatus)
                .foregroundColor(.secondary)
                .textSelection(.enabled)
        }
    }

    @ViewBuilder private var transmitterSerial: some View {
        VStack(alignment: .trailing) {
            Text(LocalizedString("Name", comment: "Transmitter name"))
                .fontWeight(.heavy)
                .fixedSize()
            Text(viewModel.transmitterName)
                .foregroundColor(.secondary)
                .textSelection(.enabled)
        }
    }

    @ViewBuilder private var calibarationTimer: some View {
        HStack(alignment: .bottom) {
            Group {
                Text("\(viewModel.nextCalibrationHours, specifier: "%.0f")")
                    .font(.system(size: 28))
                    .fontWeight(.heavy)
                    .foregroundColor(.primary)
                Text(LocalizedString("h", comment: "hour"))
                    .foregroundColor(.secondary)
            }
            Group {
                Text("\(viewModel.nextCalibrationMinutes, specifier: "%.0f")")
                    .font(.system(size: 28))
                    .fontWeight(.heavy)
                    .foregroundColor(.primary)
                Text(LocalizedString("min", comment: "minute"))
                    .foregroundColor(.secondary)
            }
        }
    }

    private func SectionItem(title: String, value: String) -> some View {
        HStack(alignment: .bottom) {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}
