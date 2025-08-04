import HealthKit
import SwiftUI

class TransmitterSettingsViewModel: ObservableObject {
    @Published var loading = false
    @Published var error = ""

    @Published var vibrationMode = false

    @Published var enableGlucoseHighAlerts = false
    @Published var glucoseHighInMgDl: Double = 180
    @Published var glucoseLowInMgDl: Double = 70

    @Published var isFallingRateEnabled = false
    @Published var isRisingRateEnabled = false
    @Published var rateFallingThreshold: Double = 0
    @Published var rateRisingThreshold: Double = 0

    public let rateAllowedOptions: [Double] = (0 ..< 8).map { 1.5 + Double($0) * 0.5 }
    public let glucoseHighAllowedOptions: [Double] = (180 ... 400).map { Double($0) }
    public let glucoseLowAllowedOptions: [Double] = (40 ... 70).map { Double($0) }

    private let cgmManager: EversenseCGMManager?
    private let unit: HKUnit
    private let formatString: NSString
    init(cgmManager: EversenseCGMManager?, unit: HKUnit) {
        self.cgmManager = cgmManager
        self.unit = unit
        formatString = unit == .milligramsPerDeciliterPerMinute ? "%.1f mg/dl/min" : "%.2f mmol/L/min"

        guard let cgmManager = cgmManager else {
            return
        }

        vibrationMode = cgmManager.state.vibrateMode ?? false
        isFallingRateEnabled = cgmManager.state.isFallingRateEnabled
        isRisingRateEnabled = cgmManager.state.isRisingRateEnabled
        enableGlucoseHighAlerts = cgmManager.state.isGlucoseHighAlarmEnabled
        glucoseHighInMgDl = Double(cgmManager.state.highGlucoseAlarmInMgDl)
        glucoseLowInMgDl = Double(cgmManager.state.lowGlucoseAlarmInMgDl)

        if let value = cgmManager.state.rateFallingThreshold {
            rateFallingThreshold = value
        }

        if let value = cgmManager.state.rateRisingThreshold {
            rateRisingThreshold = value
        }
    }

    func toHkQuantity(_ value: Double) -> HKQuantity {
        HKQuantity(unit: .milligramsPerDeciliter, doubleValue: value)
    }

    func toRateFormatted(_ value: Double) -> String {
        let value = HKQuantity(unit: .milligramsPerDeciliter, doubleValue: value)
        return NSString(format: formatString, value.doubleValue(for: unit)) as String
    }

    func saveSettings() {
        guard let cgmManager = cgmManager else {
            return
        }

        loading = true
        error = ""

        cgmManager.bluetoothManager.ensureConnected { error in
            if let error = error {
                await MainActor.run {
                    self.loading = false
                    self.error = error.describe
                }
                return
            }

            do {
                let _: SetVibrateModeResponse = try await cgmManager.bluetoothManager
                    .write(SetVibrateModePacket(enabled: self.vibrationMode))

                let _: SetHighGlucoseAlarmEnabledResponse = try await cgmManager.bluetoothManager
                    .write(SetHighGlucoseAlarmEnabledPacket(enabled: self.enableGlucoseHighAlerts))
                let _: SetHighGlucoseAlarmResponse = try await cgmManager.bluetoothManager
                    .write(SetHighGlucoseAlarmPacket(value: UInt16(self.glucoseHighInMgDl)))
                let _: SetLowGlucoseAlarmResponse = try await cgmManager.bluetoothManager
                    .write(SetLowGlucoseAlarmPacket(value: UInt16(self.glucoseLowInMgDl)))

                let _: SetRateRisingAlertResponse = try await cgmManager.bluetoothManager
                    .write(SetRateRisingAlertPacket(enabled: self.isRisingRateEnabled))
                let _: SetRateRisingThresholdResponse = try await cgmManager.bluetoothManager
                    .write(SetRateRisingThresholdPacket(value: UInt8(self.rateRisingThreshold)))
                let _: SetRateFallingAlertResponse = try await cgmManager.bluetoothManager
                    .write(SetRateFallingAlertPacket(enabled: self.isFallingRateEnabled))
                let _: SetRateFallingThresholdResponse = try await cgmManager.bluetoothManager
                    .write(SetRateFallingThresholdPacket(value: UInt8(self.rateFallingThreshold)))

                await MainActor.run {
                    self.loading = true
                    self.error = ""
                }
            } catch {}
        }
    }
}
