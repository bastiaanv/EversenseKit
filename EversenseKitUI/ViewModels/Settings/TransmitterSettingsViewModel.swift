import HealthKit
import LoopAlgorithm
import SwiftUI

class TransmitterSettingsViewModel: ObservableObject {
    @Published var loading = false
    @Published var error = ""

    @Published var vibrationMode = false

    @Published var enableGlucoseHighAlerts = false
    @Published var glucoseHighInMgDl: Double = 180
    @Published var glucoseLowInMgDl: Double = 70

    @Published var rateFallingEnabled = false
    @Published var rateRisingEnabled = false
    @Published var rateFallingThreshold: Double = 0
    @Published var rateRisingThreshold: Double = 0

    @Published var predictionLowEnabled: Bool = false
    @Published var predictionHighEnabled: Bool = false
    @Published var predictionLowTime: Double = .minutes(5)
    @Published var predictionHighTime: Double = .minutes(5)
    @Published var predictionLowThreshold: Double = 70
    @Published var predictionHighThreshold: Double = 180

    @Published var bleDisconnect: Double = .minutes(5)
    @Published var repeatLow: Double = .minutes(15)
    @Published var repeatHigh: Double = .minutes(15)

    public let rateAllowedOptions: [Double] = (0 ..< 8).map { 1.5 + Double($0) * 0.5 }
    public let glucoseHighAllowedOptions: [Double] = (0 ... 110).map { Double($0 * 2 + 180) }
    public let glucoseLowAllowedOptions: [Double] = (0 ... 15).map { Double($0 * 2 + 40) }
    public let timeAllowedOptions: [Double] = (5 ... 30).map { Double($0) }
    public let bleDisconnectAllowedOptions: [Double] = (1 ... 6).map { TimeInterval(minutes: Double($0 * 5)) }
    public let repeatLowAllowedOptions: [Double] = (1 ... 6).map { TimeInterval(minutes: Double($0 * 5)) }
    public let repeatHighAllowedOptions: [Double] = (1 ... 33).map { TimeInterval(minutes: Double($0 * 5 + 15)) }

    private let cgmManager: EversenseCGMManager?
    private let unit: LoopUnit
    private let formatString: NSString
    init(cgmManager: EversenseCGMManager?, unit: LoopUnit) {
        self.cgmManager = cgmManager
        self.unit = unit
        formatString = unit == .milligramsPerDeciliter ? "%.1f mg/dl/min" : "%.2f mmol/L/min"

        guard let cgmManager = cgmManager else {
            return
        }

        vibrationMode = cgmManager.state.vibrateMode ?? false

        enableGlucoseHighAlerts = cgmManager.state.isGlucoseHighAlarmEnabled
        glucoseHighInMgDl = Double(cgmManager.state.highGlucoseAlarmInMgDl)
        glucoseLowInMgDl = Double(cgmManager.state.lowGlucoseAlarmInMgDl)

        rateFallingEnabled = cgmManager.state.isFallingRateEnabled
        rateRisingEnabled = cgmManager.state.isRisingRateEnabled
        rateFallingThreshold = cgmManager.state.rateFallingThreshold
        rateRisingThreshold = cgmManager.state.rateRisingThreshold

        predictionLowEnabled = cgmManager.state.isPredictionLowEnabled
        predictionHighEnabled = cgmManager.state.isPredictionHighEnabled
        predictionLowTime = cgmManager.state.predictionFallingInterval
        predictionHighTime = cgmManager.state.predictionRisingInterval
        predictionLowThreshold = Double(cgmManager.state.predictionFallingThreshold)
        predictionHighThreshold = Double(cgmManager.state.predictionRisingThreshold)

        bleDisconnect = cgmManager.state.bleDisconnectTimeout
        repeatLow = cgmManager.state.repeatLowTimeout
        repeatHigh = cgmManager.state.repeatHighTimeout
    }

    func toHkQuantity(_ value: Double) -> LoopQuantity {
        LoopQuantity(unit: .milligramsPerDeciliter, doubleValue: value)
    }

    func toRateFormatted(_ value: Double) -> String {
        let value = LoopQuantity(unit: .milligramsPerDeciliter, doubleValue: value)
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
                DispatchQueue.main.async {
                    self.loading = false
                    self.error = error.describe
                }
                return
            }

            guard let peripheralManager = cgmManager.bluetoothManager.peripheralManager else {
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let transmitterSettings = TransmitterSettings(
                    vibrationMode: self.vibrationMode,

                    glucoseHighEnabled: self.enableGlucoseHighAlerts,
                    glucoseHighInMgDl: UInt16(self.glucoseHighInMgDl),
                    glucoseLowInMgDl: UInt16(self.glucoseLowInMgDl),

                    rateFallingEnabled: self.rateFallingEnabled,
                    rateRisingEnabled: self.rateRisingEnabled,
                    rateFallingThreshold: UInt8(self.rateFallingThreshold * 10),
                    rateRisingThreshold: UInt8(self.rateRisingThreshold * 10),

                    predictiveHighEnabled: self.predictionHighEnabled,
                    predictiveHighThreshold: UInt16(self.predictionHighThreshold),
                    predictiveHighTime: self.predictionHighTime,
                    predictiveLowEnabled: self.predictionLowEnabled,
                    predictiveLowThreshold: UInt16(self.predictionLowThreshold),
                    predictiveLowTime: self.predictionLowTime,

                    repeatAlarmLow: self.repeatLow,
                    repeatAlarmHigh: self.repeatHigh,
                    bleDisconnect: self.bleDisconnect
                )

                if !cgmManager.state.is365 {
                    EversenseE3.writeTransmitterSettings(peripheralManager: peripheralManager, data: transmitterSettings)
                    EversenseE3.fullSync(peripheralManager: peripheralManager, cgmManager: cgmManager)
                } else {
                    Eversense365.writeTransmitterSettings(peripheralManager: peripheralManager, data: transmitterSettings)
                    Eversense365.fullSync(peripheralManager: peripheralManager, cgmManager: cgmManager)
                }

                DispatchQueue.main.async {
                    self.loading = false
                    self.error = ""
                }
            }
        }
    }
}
