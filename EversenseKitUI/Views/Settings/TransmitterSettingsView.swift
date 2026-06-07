import LoopKitUI
import SwiftUI

struct TransmitterSettingsView: View {
    @State var pickerRateRising = false
    @State var pickerRateFalling = false
    @State var pickerPredictionHighTime = false
    @State var pickerPredictionHighThreshold = false
    @State var pickerPredictionLowTime = false
    @State var pickerPredictionLowThreshold = false
    @State var pickerGlucoseHigh = false
    @State var pickerGlucoseLow = false
    @State var pickerBleDisconnect = false
    @State var pickerRepeatLow = false
    @State var pickerRepeatHigh = false

    @EnvironmentObject private var displayGlucosePreference: DisplayGlucosePreference
    @ObservedObject var viewModel: TransmitterSettingsViewModel

    func timeFormatter(_ time: TimeInterval) -> String {
        String(format: "%.0f", time.minutes) + " " + String(localized: "min", comment: "minute")
    }

    var body: some View {
        VStack {
            List {
                toggleRow(
                    label: Text("Enable transmitter vibration", comment: "label vibration mode"),
                    hint: Text(
                        "Disable this value if you wish to not receive any alerts from your transmitter",
                        comment: "hint vibration mode"
                    ),
                    value: $viewModel.vibrationMode
                )

                valueRow(
                    labelValue: Text("Glucose low", comment: "label glucose low"),
                    hint: Text(
                        "Configure when to receive an alert for low glucose",
                        comment: "hint glucose low"
                    ),
                    statePicker: $pickerGlucoseLow,
                    valueValue: $viewModel.glucoseLowInMgDl,
                    allowedOptions: viewModel.glucoseLowAllowedOptions
                )

                toggleValueRow(
                    labelToggle: Text("Enable high glucose alerts", comment: "label toggle glucose high alert"),
                    labelValue: Text("Glucose high", comment: "label glucose high"),
                    hint: Text(
                        "Enable this value if you wish to receive alerts from your transmitter if you exceed a high glucose",
                        comment: "hint glucose high"
                    ),
                    statePicker: $pickerGlucoseHigh,
                    valueToggle: $viewModel.enableGlucoseHighAlerts,
                    valueValue: $viewModel.glucoseHighInMgDl,
                    allowedOptions: viewModel.glucoseHighAllowedOptions
                )

                toggleValueRateRow(
                    labelToggle: Text("Rising alarming enabled", comment: "label rising alarming enabled"),
                    labelValue: Text("Rate change", comment: "label alarming rate change"),
                    hint: Text(
                        "The transmitter can alarm you if you are rising too fast",
                        comment: "hint rising alarming"
                    ),
                    statePicker: $pickerRateRising,
                    valueToggle: $viewModel.rateRisingEnabled,
                    valueValue: $viewModel.rateRisingThreshold,
                    allowedOptions: viewModel.rateAllowedOptions
                )

                toggleValueRateRow(
                    labelToggle: Text("Falling alarming enabled", comment: "label falling alarming enabled"),
                    labelValue: Text("Rate change", comment: "label alarming rate change"),
                    hint: Text(
                        "The transmitter can alarm you if you are falling too fast",
                        comment: "hint falling alarming"
                    ),
                    statePicker: $pickerRateFalling,
                    valueToggle: $viewModel.rateFallingEnabled,
                    valueValue: $viewModel.rateFallingThreshold,
                    allowedOptions: viewModel.rateAllowedOptions
                )

                togglePredictionRow(
                    labelToggle: Text(
                        "Prediction high alarming enabled",
                        comment: "label prediction high alarming enabled"
                    ),
                    labelTime: Text("Prediction period", comment: "label prediction period"),
                    labelThreshold: Text("Prediction target", comment: "label prediction target"),
                    hint: Text(
                        "The transmitter can alarm you if it predictions you are rising above the threshold",
                        comment: "hint rising prediction"
                    ),
                    stateTimePicker: $pickerPredictionHighTime,
                    stateThresholdPicker: $pickerPredictionHighThreshold,
                    valueToggle: $viewModel.predictionHighEnabled,
                    valueTime: $viewModel.predictionHighTime,
                    valueThreshold: $viewModel.predictionHighThreshold,
                    allowedTimeOptions: viewModel.timeAllowedOptions,
                    allowedThresholdOptions: viewModel.glucoseHighAllowedOptions
                )

                togglePredictionRow(
                    labelToggle: Text(
                        "Prediction Low alarming enabled",
                        comment: "label prediction high alarming enabled"
                    ),
                    labelTime: Text("Prediction period", comment: "label prediction period"),
                    labelThreshold: Text("Prediction target", comment: "label prediction target"),
                    hint: Text(
                        "The transmitter can alarm you if it predictions you are falling below the threshold",
                        comment: "hint falling prediction"
                    ),
                    stateTimePicker: $pickerPredictionLowTime,
                    stateThresholdPicker: $pickerPredictionLowThreshold,
                    valueToggle: $viewModel.predictionLowEnabled,
                    valueTime: $viewModel.predictionLowTime,
                    valueThreshold: $viewModel.predictionLowThreshold,
                    allowedTimeOptions: viewModel.timeAllowedOptions,
                    allowedThresholdOptions: viewModel.glucoseLowAllowedOptions
                )

                Section {
                    HStack {
                        Text("Low Snooze", comment: "label low snooze")
                            .foregroundStyle(pickerRepeatLow ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                        Spacer()
                        Text(timeFormatter(viewModel.repeatLow))
                            .foregroundStyle(pickerRepeatLow ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                    }
                    .onTapGesture {
                        pickerRepeatLow.toggle()
                    }

                    if pickerRepeatLow {
                        Picker(selection: $viewModel.repeatLow) {
                            ForEach(viewModel.repeatLowAllowedOptions, id: \.self) { item in
                                Text(timeFormatter(item))
                            }
                        } label: { EmptyView() }
                        .pickerStyle(.wheel)
                    }

                    HStack {
                        Text("High Snooze", comment: "label high snooze")
                            .foregroundStyle(pickerRepeatHigh ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                        Spacer()
                        Text(timeFormatter(viewModel.repeatHigh))
                            .foregroundStyle(pickerRepeatHigh ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                    }
                    .onTapGesture {
                        pickerRepeatHigh.toggle()
                    }

                    if pickerRepeatHigh {
                        Picker(selection: $viewModel.repeatHigh) {
                            ForEach(viewModel.repeatHighAllowedOptions, id: \.self) { item in
                                Text(timeFormatter(item))
                            }
                        } label: { EmptyView() }
                        .pickerStyle(.wheel)
                    }
                } footer: {
                    Text(
                        "Configure how much time should be configured between each low or high glucose alert",
                        comment: "label lowhigh snooze"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }

                Section {
                    HStack {
                        Text("BLE disconnect alert", comment: "label ble disconnect")
                            .foregroundStyle(pickerBleDisconnect ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                        Spacer()
                        Text(timeFormatter(viewModel.bleDisconnect))
                            .foregroundStyle(pickerBleDisconnect ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                    }
                    .onTapGesture {
                        pickerBleDisconnect.toggle()
                    }

                    if pickerBleDisconnect {
                        Picker(selection: $viewModel.bleDisconnect) {
                            ForEach(viewModel.bleDisconnectAllowedOptions, id: \.self) { item in
                                Text(timeFormatter(item))
                            }
                        } label: { EmptyView() }
                        .pickerStyle(.wheel)
                    }
                } footer: {
                    Text(
                        "Configure how long the transmitter is allowed to be disconnected from your phone",
                        comment: "label ble disconnect footer"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
                    Text("Save", comment: "Text for continue button")
                }
            }
            .buttonStyle(ActionButtonStyle())
            .padding([.bottom, .horizontal])
            .disabled(viewModel.loading)
        }
        .navigationBarTitle(String(localized: "Transmitter settings", comment: "Title for user options"))
    }

    @ViewBuilder private func toggleRow(label: Text, hint: Text, value: Binding<Bool>) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 20) {
                Toggle(isOn: value) {
                    label
                }
            }
        } footer: {
            hint
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private func toggleValueRateRow(
        labelToggle: Text,
        labelValue: Text,
        hint: Text,
        statePicker: Binding<Bool>,
        valueToggle: Binding<Bool>,
        valueValue: Binding<Double>,
        allowedOptions: [Double]
    ) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 20) {
                Toggle(isOn: valueToggle) {
                    labelToggle
                }

                if valueToggle.wrappedValue {
                    HStack {
                        labelValue
                            .foregroundStyle(statePicker.wrappedValue ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                        Spacer()
                        Text(viewModel.toRateFormatted(valueValue.wrappedValue))
                            .foregroundStyle(statePicker.wrappedValue ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                    }
                    .onTapGesture {
                        statePicker.wrappedValue.toggle()
                    }

                    if statePicker.wrappedValue {
                        Picker(selection: valueValue) {
                            ForEach(allowedOptions, id: \.self) { item in
                                Text(viewModel.toRateFormatted(item))
                            }
                        } label: { EmptyView() }
                        .pickerStyle(.wheel)
                    }
                }
            }
        } footer: {
            hint
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private func toggleValueRow(
        labelToggle: Text,
        labelValue: Text,
        hint: Text,
        statePicker: Binding<Bool>,
        valueToggle: Binding<Bool>,
        valueValue: Binding<Double>,
        allowedOptions: [Double]
    ) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 20) {
                Toggle(isOn: valueToggle) {
                    labelToggle
                }

                if valueToggle.wrappedValue {
                    HStack {
                        labelValue
                            .foregroundStyle(statePicker.wrappedValue ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                        Spacer()
                        Text(displayGlucosePreference.format(viewModel.toHkQuantity(valueValue.wrappedValue)))
                            .foregroundStyle(statePicker.wrappedValue ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                    }
                    .onTapGesture {
                        statePicker.wrappedValue.toggle()
                    }

                    if statePicker.wrappedValue {
                        Picker(selection: valueValue) {
                            ForEach(allowedOptions, id: \.self) { item in
                                Text(displayGlucosePreference.format(viewModel.toHkQuantity(item)))
                            }
                        } label: { EmptyView() }
                        .pickerStyle(.wheel)
                    }
                }
            }
        } footer: {
            hint
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private func togglePredictionRow(
        labelToggle: Text,
        labelTime: Text,
        labelThreshold: Text,
        hint: Text,
        stateTimePicker: Binding<Bool>,
        stateThresholdPicker: Binding<Bool>,
        valueToggle: Binding<Bool>,
        valueTime: Binding<TimeInterval>,
        valueThreshold: Binding<Double>,
        allowedTimeOptions: [TimeInterval],
        allowedThresholdOptions: [Double]
    ) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 20) {
                Toggle(isOn: valueToggle) {
                    labelToggle
                }

                if valueToggle.wrappedValue {
                    HStack {
                        labelTime
                            .foregroundStyle(stateTimePicker.wrappedValue ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                        Spacer()
                        Text(timeFormatter(valueTime.wrappedValue))
                            .foregroundStyle(stateTimePicker.wrappedValue ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                    }
                    .onTapGesture {
                        stateTimePicker.wrappedValue.toggle()
                    }

                    if stateTimePicker.wrappedValue {
                        Picker(selection: valueTime) {
                            ForEach(allowedTimeOptions, id: \.self) { item in
                                Text(timeFormatter(item))
                            }
                        } label: { EmptyView() }
                        .pickerStyle(.wheel)
                    }

                    HStack {
                        labelThreshold
                            .foregroundStyle(stateThresholdPicker.wrappedValue ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                        Spacer()
                        Text(displayGlucosePreference.format(viewModel.toHkQuantity(valueThreshold.wrappedValue)))
                            .foregroundStyle(stateThresholdPicker.wrappedValue ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                    }
                    .onTapGesture {
                        stateThresholdPicker.wrappedValue.toggle()
                    }

                    if stateThresholdPicker.wrappedValue {
                        Picker(selection: valueThreshold) {
                            ForEach(allowedThresholdOptions, id: \.self) { item in
                                Text(displayGlucosePreference.format(viewModel.toHkQuantity(item)))
                            }
                        } label: { EmptyView() }
                        .pickerStyle(.wheel)
                    }
                }
            }
        } footer: {
            hint
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private func valueRow(
        labelValue: Text,
        hint: Text,
        statePicker: Binding<Bool>,
        valueValue: Binding<Double>,
        allowedOptions: [Double]
    ) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    labelValue
                        .foregroundStyle(statePicker.wrappedValue ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                    Spacer()
                    Text(displayGlucosePreference.format(viewModel.toHkQuantity(valueValue.wrappedValue)))
                        .foregroundStyle(statePicker.wrappedValue ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                }
                .onTapGesture {
                    statePicker.wrappedValue.toggle()
                }

                if statePicker.wrappedValue {
                    Picker(selection: valueValue) {
                        ForEach(allowedOptions, id: \.self) { item in
                            Text(displayGlucosePreference.format(viewModel.toHkQuantity(item)))
                        }
                    } label: { EmptyView() }
                    .pickerStyle(.wheel)
                }
            }
        } footer: {
            hint
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
