extension Eversense365 {
    class GetCalibrationInfoResponse {
        let currentPhase: CalibrationPhase
        let calibrationReadiness: CalibrationReadiness
        let calibrationMode: CalibrationMode
        let countCalibrations: UInt8
        let nextCalibration: Date
        let lastCalibration: Date

        init(
            currentPhase: CalibrationPhase,
            calibrationReadiness: CalibrationReadiness,
            calibrationMode: CalibrationMode,
            countCalibrations: UInt8,
            nextCalibration: Date,
            lastCalibration: Date
        ) {
            self.currentPhase = currentPhase
            self.calibrationReadiness = calibrationReadiness
            self.calibrationMode = calibrationMode
            self.countCalibrations = countCalibrations
            self.nextCalibration = nextCalibration
            self.lastCalibration = lastCalibration
        }
    }

    class GetCalibrationInfoPacket: BasePacket {
        typealias T = GetCalibrationInfoResponse

        var responseType: UInt8 {
            PacketIds.ReadResponseId.rawValue
        }

        var responseId: UInt8? {
            ReadIds.CalibrationInfo.rawValue
        }

        func getRequestData() -> Data {
            Data([PacketIds.ReadCommandId.rawValue, ReadIds.CalibrationInfo.rawValue])
        }

        /// 42 1D -> CmdType & CmdId
        /// 00 -> Current calibration phase
        /// 06 -> Ready for calibration (CALIBRATION_READINESS)
        /// 00 00 00 00 00 00 00 00 -> Next calibration datetime
        /// 00 -> Number of calibrations per day
        /// 00 -> Number of calibrations in this Phase
        /// 00 00 -> Minutes allowed before next calibration due
        /// 00 00 -> Minutes allowed after next calibration due
        /// 00 00 -> Number of completed calibrations
        /// 00 00 00 00 00 00 00 00 -> Start datetime of current phase
        /// 00 00 -> Sensor lifetime
        /// 00 00 -> Warmup duration
        /// 00 00 -> Minutes until next calibration
        /// 00 00 00 00 00 00 00 00 -> Last calibration datetime
        func parseResponse(data: Data) -> Eversense365.GetCalibrationInfoResponse {
            GetCalibrationInfoResponse(
                currentPhase: CalibrationPhase.from365(rawValue: data[Offset.CURRENT_CALIBRATION_PHASE]),
                calibrationReadiness: CalibrationReadiness(rawValue: data[Offset.READY_FOR_CALIBRATIONS]) ?? .Unknown,
                calibrationMode: CalibrationMode.from365(rawValue: data[Offset.CALIBRATIONS_PER_DAY]),
                countCalibrations: data[Offset.CALIBRATIONS_IN_PHASE],
                nextCalibration: Date.fromUnix2000(
                    data: data
                        .subdata(in: Offset.NEXT_CALIBRATION_DATETIME_START ..< Offset.NEXT_CALIBRATION_DATETIME_END)
                ),
                lastCalibration: Date.fromUnix2000(
                    data: data
                        .subdata(in: Offset.LAST_CALIBRATION_DATETIME_START ..< Offset.LAST_CALIBRATION_DATETIME_END)
                ),
            )
        }

        enum Offset {
            static let CURRENT_CALIBRATION_PHASE = 2
            static let READY_FOR_CALIBRATIONS = 3

            static let NEXT_CALIBRATION_DATETIME_START = 4
            static let NEXT_CALIBRATION_DATETIME_END = 12

            static let CALIBRATIONS_PER_DAY = 12
            static let CALIBRATIONS_IN_PHASE = 13

            static let MINUTES_ALLOWED_BEFORE_NEXT_CALIBRATION_DUE_START = 14
            static let MINUTES_ALLOWED_BEFORE_NEXT_CALIBRATION_DUE_END = 16

            static let MINUTES_ALLOWED_AFTER_NEXT_CALIBRATION_DUE_START = 16
            static let MINUTES_ALLOWED_AFTER_NEXT_CALIBRATION_DUE_END = 18

            static let COMPLETED_CALIBRATIONS_START = 18
            static let COMPLETED_CALIBRATIONS_END = 20

            static let START_CURRENT_PHASE_START = 20
            static let START_CURRENT_PHASE_END = 28

            static let SENSOR_LIFETIME_START = 28
            static let SENSOR_LIFETIME_END = 30

            static let WARMUP_DURATION_START = 30
            static let WARMUP_DURATION_END = 32

            static let MINUTES_UNTIL_NEXT_CALIBRATION_START = 32
            static let MINUTES_UNTIL_NEXT_CALIBRATION_END = 34

            static let LAST_CALIBRATION_DATETIME_START = 34
            static let LAST_CALIBRATION_DATETIME_END = 42
        }
    }
}
