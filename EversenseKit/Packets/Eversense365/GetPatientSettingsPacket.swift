extension Eversense365 {
    class GetPatientSettingsResponse {
        let vibrateMode: Bool
        let disconnectTimeout: TimeInterval
        let highGlucoseEnabled: Bool
        let lowGlucoseAlarmInMgDl: UInt16
        let highGlucoseAlarmInMgDl: UInt16
        let predictionLowEnabled: Bool
        let predictionHighEnabled: Bool
        let predictionFallingInterval: TimeInterval
        let predictionRisingInterval: TimeInterval
        let predictionFallingThreshold: UInt16
        let predictionRisingThreshold: UInt16
        let rateFallingEnabled: Bool
        let rateRisingEnabled: Bool
        let rateFallingThreshold: Double
        let rateRisingThreshold: Double
        let repeatLowTimeout: TimeInterval
        let repeatHighTimeout: TimeInterval

        init(
            vibrateMode: Bool,
            disconnectTimeout: TimeInterval,
            highGlucoseEnabled: Bool,
            highGlucoseAlarmInMgDl: UInt16,
            lowGlucoseAlarmInMgDl: UInt16,
            predictionLowEnabled: Bool,
            predictionHighEnabled: Bool,
            predictionFallingInterval: TimeInterval,
            predictionRisingInterval: TimeInterval,
            predictionFallingThreshold: UInt16,
            predictionRisingThreshold: UInt16,
            rateFallingEnabled: Bool,
            rateRisingEnabled: Bool,
            rateFallingThreshold: Double,
            rateRisingThreshold: Double,
            repeatLowTimeout: TimeInterval,
            repeatHighTimeout: TimeInterval
        ) {
            self.vibrateMode = vibrateMode
            self.disconnectTimeout = disconnectTimeout
            self.highGlucoseEnabled = highGlucoseEnabled
            self.highGlucoseAlarmInMgDl = highGlucoseAlarmInMgDl
            self.lowGlucoseAlarmInMgDl = lowGlucoseAlarmInMgDl
            self.predictionLowEnabled = predictionLowEnabled
            self.predictionHighEnabled = predictionHighEnabled
            self.predictionFallingInterval = predictionFallingInterval
            self.predictionRisingInterval = predictionRisingInterval
            self.predictionFallingThreshold = predictionFallingThreshold
            self.predictionRisingThreshold = predictionRisingThreshold
            self.rateFallingEnabled = rateFallingEnabled
            self.rateRisingEnabled = rateRisingEnabled
            self.rateFallingThreshold = rateFallingThreshold
            self.rateRisingThreshold = rateRisingThreshold
            self.repeatLowTimeout = repeatLowTimeout
            self.repeatHighTimeout = repeatHighTimeout
        }
    }

    class GetPatientSettingsPacket: BasePacket {
        typealias T = GetPatientSettingsResponse

        var responseType: UInt8 {
            PacketIds.ReadResponseId.rawValue
        }

        var responseId: UInt8? {
            ReadIds.PatientInformation.rawValue
        }

        func getRequestData() -> Data {
            Data([PacketIds.ReadCommandId.rawValue, ReadIds.PatientInformation.rawValue])
        }

        /// Message parsed:
        /// 42 21 -> CmdType & CmdId
        /// 44 33 30 36 33 36 36 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 -> Transmitter name
        /// 38 2E 30 2E 34 00 00 00 00 00 00 00 00 00 00 00 -> Recent MMA Version
        /// 00 -> Is clinical mode enabled
        /// 00 -> Is do not Disturb Enabled
        /// 2C 01 -> BLE connect time in sec -> 300s
        /// 46 00 -> Low sugar target in mg/dl
        /// B4 00 -> High sugar target in mg/dl
        /// 00 -> Alarm rate falling enabled
        /// 19 -> Alarm rate falling threshold
        /// 00 -> Alarm rate rising enabled
        /// 19 -> Alarm rate rising threshold
        /// 00 -> Alarm Predictive Low enabled
        /// 14 -> Alarm Predictive Low Time
        /// 00 -> Alarm Predictive High enabled
        /// 14 -> Alarm Predictive High Time
        /// 01 -> Alarm High Glucose enabled
        /// FA 00 -> Alarm High Glucose Threshold
        /// 1E -> Alarm High Glucose Repeat Interval
        /// 41 00 -> Alarm Low Glucose Threshold
        /// 0F -> Alarm Low Glucose Repeat Interval
        /// 34 -> Battery Temp Thresh Mode Change
        /// 44 -> Battery Temp Thresh Warn
        func parseResponse(data: Data) -> GetPatientSettingsResponse {
            let disconnectTimeout = UInt16(data[Offset.DISCONNECT_TIMEOUT]) | (UInt16(data[Offset.DISCONNECT_TIMEOUT + 1]) << 8)

            return GetPatientSettingsResponse(
                vibrateMode: data[Offset.IS_DO_NOT_DISTURB_ENABLED] == 0x00,
                disconnectTimeout: TimeInterval(seconds: Double(disconnectTimeout)),
                highGlucoseEnabled: data[Offset.ALARM_HIGH_GLUCOSE_ENABLED] != 0x00,
                highGlucoseAlarmInMgDl: UInt16(data[Offset.ALARM_HIGH_GLUCOSE_THRESHOLD]) |
                    (UInt16(data[Offset.ALARM_HIGH_GLUCOSE_THRESHOLD + 1]) << 8),
                lowGlucoseAlarmInMgDl: UInt16(data[Offset.ALARM_LOW_GLUCOSE_THRESHOLD]) |
                    (UInt16(data[Offset.ALARM_LOW_GLUCOSE_THRESHOLD + 1]) << 8),
                predictionLowEnabled: data[Offset.ALARM_PREDICTIVE_LOW_ENABLED] != 0x00,
                predictionHighEnabled: data[Offset.ALARM_PREDICTIVE_HIGH_ENABLED] != 0x00,
                predictionFallingInterval: .minutes(Double(data[Offset.ALARM_PREDICTIVE_LOW_TIME])),
                predictionRisingInterval: .minutes(Double(data[Offset.ALARM_PREDICTIVE_HIGH_TIME])),
                predictionFallingThreshold: UInt16(data[Offset.LOW_SUGAR_TARGET]) |
                    (UInt16(data[Offset.LOW_SUGAR_TARGET + 1]) << 8),
                predictionRisingThreshold: UInt16(data[Offset.HIGH_SUGAR_TARGET]) |
                    (UInt16(data[Offset.HIGH_SUGAR_TARGET + 1]) << 8),
                rateFallingEnabled: data[Offset.ALARM_RATE_FALLING_ENABLED] != 0x00,
                rateRisingEnabled: data[Offset.ALARM_RATE_RISING_ENABLED] != 0x00,
                rateFallingThreshold: Double(data[Offset.ALARM_RATE_FALLING_THRESHOLD]) / 10,
                rateRisingThreshold: Double(data[Offset.ALARM_RATE_RISING_THRESHOLD]) / 10,
                repeatLowTimeout: TimeInterval(minutes: Double(data[Offset.ALARM_LOW_GLUCOSE_REPEAT_INTERVAL])),
                repeatHighTimeout: TimeInterval(minutes: Double(data[Offset.ALARM_HIGH_GLUCOSE_REPEAT_INTERVAL]))
            )
        }

        enum Offset {
            static let TRANSMITTER_NAME_START = 2
            static let TRANSMITTER_NAME_END = 27

            static let RECENT_MMA_VERSION_START = 27
            static let RECENT_MMA_VERSION_END = 43

            static let IS_CLINICAL_MODE_ENABLED = 43
            static let IS_DO_NOT_DISTURB_ENABLED = 44
            static let DISCONNECT_TIMEOUT = 45
            static let LOW_SUGAR_TARGET = 47
            static let HIGH_SUGAR_TARGET = 49
            static let ALARM_RATE_FALLING_ENABLED = 51
            static let ALARM_RATE_FALLING_THRESHOLD = 52
            static let ALARM_RATE_RISING_ENABLED = 53
            static let ALARM_RATE_RISING_THRESHOLD = 54
            static let ALARM_PREDICTIVE_LOW_ENABLED = 55
            static let ALARM_PREDICTIVE_LOW_TIME = 56
            static let ALARM_PREDICTIVE_HIGH_ENABLED = 57
            static let ALARM_PREDICTIVE_HIGH_TIME = 58
            static let ALARM_HIGH_GLUCOSE_ENABLED = 59
            static let ALARM_HIGH_GLUCOSE_THRESHOLD = 60
            static let ALARM_HIGH_GLUCOSE_REPEAT_INTERVAL = 62
            static let ALARM_LOW_GLUCOSE_THRESHOLD = 63
            static let ALARM_LOW_GLUCOSE_REPEAT_INTERVAL = 65
            static let BATTERY_TEMP_THRESH_MODE_CHANGE = 66
            static let BATTERY_TEMP_THRESH_WARN = 67
        }
    }
}
