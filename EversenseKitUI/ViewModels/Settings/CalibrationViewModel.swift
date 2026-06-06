import HealthKit
import LoopAlgorithm
import SwiftUI

class CalibrationViewModel: ObservableObject {
    @Published var glucose: UInt16
    @Published var time = Date.now
    @Published var isLoading = false
    @Published var error = ""

    let allowedGlucoseValuesMgDl = Array(UInt16(60) ... UInt16(400))
    let allowedGlucoseValuesMmolL = Array(UInt16(33) ... UInt16(220))

    private let logger = EversenseLogger(category: "CalibrationViewModel")
    private let cgmManager: EversenseCGMManager?
    private let done: () -> Void
    private let unit: LoopUnit
    public let allowCalibrations = FeatureFlags.ALLOW_CALIBRATION
    init(cgmManager: EversenseCGMManager?, _ unit: LoopUnit, _ done: @escaping () -> Void) {
        self.cgmManager = cgmManager
        self.unit = unit
        self.done = done
        glucose = unit == .milligramsPerDeciliter ? 100 : 56
    }

    func calibrate() {
        guard let cgmManager = cgmManager else {
            logger.warning("No CGMManager...")
            return
        }

        error = ""
        isLoading = true

        var glucose = glucose
        if unit == .millimolesPerLiter {
            let mgdl = LoopQuantity(unit: unit, doubleValue: Double(glucose) / 10).doubleValue(for: .milligramsPerDeciliter)
            glucose = UInt16(mgdl)
        }

        do {
            if cgmManager.state.is365 {
                try Eversense365.calibrateSensors(cgmManager: cgmManager, glucoseInMgDl: glucose, timestamp: time)
            } else {
                try EversenseE3.calibrateSensors(cgmManager: cgmManager, glucoseInMgDl: glucose, timestamp: time)
            }

            if cgmManager.state.shouldUploadToEversenseDMS {
                Task {
                    if await DMSApi.uploadDeviceEvents(
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
                    ) == false {
                        self.logger.warning("Failed to upload device events")
                    }
                }
            }

            cgmManager.heartbeathOperation {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.done()
                }
            }
        } catch {
            logger.error("Error during calibration: \(error)")
            DispatchQueue.main.async {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
