import HealthKit
import SwiftUI

class CalibrationViewModel: ObservableObject {
    @Published var glucose: UInt16
    @Published var time = Date.now
    @Published var isLoading = false
    @Published var error = ""

    let allowedGlucoseValuesMgDl = Array(UInt16(60) ... UInt16(400))
    let allowedGlucoseValuesMmolL = Array(UInt16(33) ... UInt16(220))

    private let logger = EversenseLogger(category: "CalibrationViewModel")
    private let cgmManager: EversenseCGMManager
    private let done: () -> Void
    private let unit: HKUnit
    public let allowCalibrations = FeatureFlags.ALLOW_CALIBRATION
    init(cgmManager: EversenseCGMManager, _ unit: HKUnit, _ done: @escaping () -> Void) {
        self.cgmManager = cgmManager
        self.unit = unit
        self.done = done
        glucose = unit == .milligramsPerDeciliter ? 100 : 56
    }

    func calibrate() {
        error = ""
        isLoading = true

        let glucose = getGlucose()
        let time = self.time

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else {
                return
            }

            do {
                if cgmManager.state.is365 {
                    try Eversense365.calibrateSensors(cgmManager: cgmManager, glucoseInMgDl: glucose, timestamp: time)
                } else {
                    try EversenseE3.calibrateSensors(cgmManager: cgmManager, glucoseInMgDl: glucose, timestamp: time)
                }

                if cgmManager.state.shouldUploadToEversenseDMS {
                    self.startDMSUpload(cgmManager: cgmManager, glucose: glucose)
                }

                // Allow Transmitter to process calibration
                Thread.sleep(forTimeInterval: .seconds(2))

                cgmManager.heartbeathOperation(force: true) {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.done()
                    }
                }
            } catch {
                self.logger.error("Error during calibration: \(error)")
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    private func getGlucose() -> UInt16 {
        if unit == .millimolesPerLiter {
            let mgdl = HKQuantity(unit: unit, doubleValue: Double(glucose) / 10).doubleValue(for: .milligramsPerDeciliter)
            return UInt16(mgdl)
        } else {
            return glucose
        }
    }

    private func startDMSUpload(cgmManager: EversenseCGMManager, glucose: UInt16) {
        Task {
            let result = await DMSApi.uploadDeviceEvents(
                cgmManager: cgmManager,
                sensorId: cgmManager.state.sensorId,
                readings: [],
                calibrations: [
                    CalibrationEvent(
                        glucoseInMgDl: glucose,
                        datetime: time
                    )
                ],
                alerts: []
            )

            if !result.isSuccess {
                self.logger.warning("Failed to upload device events: \(String(describing: result))")
            }
        }
    }
}
