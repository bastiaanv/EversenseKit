import LoopKitUI
import SwiftUI

struct TransmitterSettingsView: View {
    @State var pickerRisingRate = false
    @State var pickerFallingRate = false
    @State var pickerGlucoseHigh = false
    @State var pickerGlucoseLow = false

    @EnvironmentObject private var displayGlucosePreference: DisplayGlucosePreference
    @ObservedObject var viewModel: TransmitterSettingsViewModel

    var body: some View {
        VStack {
            List {
                toggleRow(
                    label: LocalizedString("Enable vibration", comment: "label vibration mode"),
                    hint: LocalizedString(
                        "Disable this value if you wish to not receive any alerts from your transmitter",
                        comment: "hint vibration mode"
                    ),
                    value: $viewModel.vibrationMode
                )

                if viewModel.vibrationMode {
                    toggleValueRow(
                        labelToggle: LocalizedString("Enable high glucose alerts", comment: "label toggle glucose high alert"),
                        labelValue: LocalizedString("Glucose high", comment: "label glucose high"),
                        hint: LocalizedString(
                            "Enable this value if you wish to receive alerts from your transmitter if you exceed a high glucose",
                            comment: "hint glucose high"
                        ),
                        statePicker: $pickerGlucoseHigh,
                        valueToggle: $viewModel.enableGlucoseHighAlerts,
                        valueValue: $viewModel.glucoseHighInMgDl,
                        allowedOptions: viewModel.glucoseHighAllowedOptions
                    )

                    valueRow(
                        labelValue: LocalizedString("Glucose low", comment: "label glucose high"),
                        hint: LocalizedString(
                            "Configure when to receive an alert for low glucose",
                            comment: "hint glucose low"
                        ),
                        statePicker: $pickerGlucoseLow,
                        valueValue: $viewModel.glucoseLowInMgDl,
                        allowedOptions: viewModel.glucoseLowAllowedOptions
                    )

                    toggleValueRateRow(
                        labelToggle: LocalizedString("Rising alarming enabled", comment: "label rising alarming enabled"),
                        labelValue: LocalizedString("Rate change", comment: "label alarming rate change"),
                        hint: LocalizedString(
                            "The transmitter can alarm you if you are rising too fast",
                            comment: "hint rising alarming"
                        ),
                        statePicker: $pickerRisingRate,
                        valueToggle: $viewModel.isRisingRateEnabled,
                        valueValue: $viewModel.rateRisingThreshold,
                        allowedOptions: viewModel.rateAllowedOptions
                    )

                    toggleValueRateRow(
                        labelToggle: LocalizedString("Falling alarming enabled", comment: "label falling alarming enabled"),
                        labelValue: LocalizedString("Rate change", comment: "label alarming rate change"),
                        hint: LocalizedString(
                            "The transmitter can alarm you if you are falling too fast",
                            comment: "hint falling alarming"
                        ),
                        statePicker: $pickerFallingRate,
                        valueToggle: $viewModel.isFallingRateEnabled,
                        valueValue: $viewModel.rateFallingThreshold,
                        allowedOptions: viewModel.rateAllowedOptions
                    )
                }
            }

            Spacer()

            if !viewModel.error.isEmpty {
                Text(viewModel.error)
                    .foregroundStyle(.red)
            }

            Button(action: viewModel.saveSettings) {
                if viewModel.loading {
                    ActivityIndicator(isAnimating: .constant(true), style: .medium)
                } else {
                    Text(LocalizedString("Continue", comment: "Text for continue button"))
                }
            }
            .buttonStyle(ActionButtonStyle())
            .padding([.bottom, .horizontal])
            .disabled(viewModel.loading)
        }
        .navigationBarTitle(LocalizedString("User options", comment: "Title for user options"))
    }

    @ViewBuilder private func toggleRow(label: String, hint: String, value: Binding<Bool>) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 20) {
                Toggle(isOn: value) {
                    Text(label)
                }
                Text(hint)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder private func toggleValueRateRow(
        labelToggle: String,
        labelValue: String,
        hint: String,
        statePicker: Binding<Bool>,
        valueToggle: Binding<Bool>,
        valueValue: Binding<Double>,
        allowedOptions: [Double]
    ) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 20) {
                Toggle(isOn: valueToggle) {
                    Text(labelToggle)
                }
                HStack {
                    Text(labelValue)
                        .foregroundStyle(pickerRisingRate ? .blue : .primary)
                    Spacer()
                    Text(viewModel.toRateFormatted(valueValue.wrappedValue))
                        .foregroundStyle(pickerRisingRate ? .blue : .secondary)
                }
                .onTapGesture {
                    statePicker.wrappedValue.toggle()
                }

                if statePicker.wrappedValue {
                    ResizeablePicker(
                        selection: valueValue,
                        data: allowedOptions,
                        formatter: { viewModel.toRateFormatted($0) }
                    )
                }

                Text(hint)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder private func toggleValueRow(
        labelToggle: String,
        labelValue: String,
        hint: String,
        statePicker: Binding<Bool>,
        valueToggle: Binding<Bool>,
        valueValue: Binding<Double>,
        allowedOptions: [Double]
    ) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 20) {
                Toggle(isOn: valueToggle) {
                    Text(labelToggle)
                }
                HStack {
                    Text(labelValue)
                    Spacer()
                    Text(displayGlucosePreference.format(viewModel.toHkQuantity(valueValue.wrappedValue)))
                        .foregroundStyle(.secondary)
                }
                .onTapGesture {
                    statePicker.wrappedValue.toggle()
                }

                if statePicker.wrappedValue {
                    ResizeablePicker(
                        selection: valueValue,
                        data: allowedOptions,
                        formatter: { displayGlucosePreference.format(viewModel.toHkQuantity($0)) }
                    )
                }

                Text(hint)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder private func valueRow(
        labelValue: String,
        hint: String,
        statePicker: Binding<Bool>,
        valueValue: Binding<Double>,
        allowedOptions: [Double]
    ) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(labelValue)
                    Spacer()
                    Text(displayGlucosePreference.format(viewModel.toHkQuantity(valueValue.wrappedValue)))
                        .foregroundStyle(.secondary)
                }
                .onTapGesture {
                    statePicker.wrappedValue.toggle()
                }

                if statePicker.wrappedValue {
                    ResizeablePicker(
                        selection: valueValue,
                        data: allowedOptions,
                        formatter: { displayGlucosePreference.format(viewModel.toHkQuantity($0)) }
                    )
                }

                Text(hint)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
