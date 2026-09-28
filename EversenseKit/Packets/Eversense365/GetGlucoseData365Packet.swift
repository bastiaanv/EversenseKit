import LoopKit

extension Eversense365 {
    class GetGlucoseDataResponse {
        let trend: GlucoseTrend
        let glucoseDatetime: Date
        let glucoseInMgDl: UInt16
        let raw: String
        let sensorId: Data

        init(trend: GlucoseTrend, glucoseDatetime: Date, glucoseInMgDl: UInt16, raw: String, sensorId: Data) {
            self.trend = trend
            self.glucoseDatetime = glucoseDatetime
            self.glucoseInMgDl = glucoseInMgDl
            self.raw = raw
            self.sensorId = sensorId
        }
    }

    class GetGlucoseDataPacket: BasePacket {
        typealias T = GetGlucoseDataResponse

        var responseType: UInt8 {
            PacketIds.ReadResponseId.rawValue
        }

        var responseId: UInt8? {
            ReadIds.GlucoseData.rawValue
        }

        func getRequestData() -> Data {
            Data([PacketIds.ReadCommandId.rawValue, ReadIds.GlucoseData.rawValue])
        }

        /// 42 1F -> CmdType & CmdId
        /// B2 74 4A BD C2 00 00 00 -> Current datetime
        /// 01 -> Sensor type
        /// 0A -> Sensor ID length
        /// 14 71 15 71 87 2A 3C 60 18 E0 -> Sensor ID
        /// 2A DC 45 BD C2 00 00 00 -> glucose datetime
        /// 45 00 -> Glucose value = 69 mg/dl = 3.8 mmol/L
        /// A1 00 -> Signal strength
        /// 00 00 -> Glucose unavailable reason (undocumented enum)
        /// 00000000E107911E03025F17151BFD014530E21E0C023D1D8E030C02862D28000000750000000D027E1EFD01131EA4140C025230D11E0B027D1D78030D02892D28000000EA000000CF08B61EAA015316E51AB60140308C1EB801741DD403B701872D280000005F010000B301A71EB201561FD113B0016430831EB801481EBC03B801842D28000000 -> Measurement (length 136 bytes)
        /// 00 00 -> Trend value
        /// 04 -> Trend direction
        /// 00 00 00 00 -> Sensor temperature
        /// 00 00 00 00 -> MSP
        /// 00 00 00 00 -> MEP spike
        /// 00 00 00 00 -> MEP low ref
        /// 00 00 00 00 -> MEP drift
        /// 00 00 00 00 -> MEP ref channel
        /// 00 00 00 00 -> MEP value
        /// 5F -> Battery percentage
        /// 00 00 00 00 -> Transmitter temperature
        /// 00 00 00 00 -> AccelerometerXAxis
        /// 00 00 00 00 -> AccelerometerYAxis
        /// 00 00 00 00 -> AccelerometerZAxis

        /// Parsed message:
        /// 42 1F -> CmdType & CmdId
        /// F6 95 86 CB C1 00 00 00 -> Current datetime
        /// 00 -> Sensor type
        /// 0A -> Sensor ID length
        /// 00 00 00 00 00 00 00 00 00 00 -> Sensor ID (size is based on previous value)
        /// 00 18 82 cb c1 00 00 00 -> Most recent glucose datetime
        /// bc 00 -> Most recent glucose value
        /// 32 00 -> Signal strength
        /// 00 00 -> Glucose unavailable reason (undocumented enum)
        /// 00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 -> Measurement (length 136 bytes)
        /// 05 00 -> Trend value
        /// 04 -> Trend direction
        /// 00 00 00 00 -> Sensor temperature
        /// 00 00 00 00 -> MSP
        /// 00 00 00 00 -> MEP spike
        /// 00 00 00 00 -> MEP low ref
        /// 00 00 00 00 -> MEP drift
        /// 00 00 00 00 -> MEP ref channel
        /// 00 00 00 00 -> MEP value
        /// 07 -> Battery percentage
        /// 00 00 00 00 -> Transmitter temperature
        /// 00 00 00 00 -> AccelerometerXAxis
        /// 00 00 00 00 -> AccelerometerYAxis
        /// 00 00 00 00 -> AccelerometerZAxis
        func parseResponse(data: Data) -> Eversense365.GetGlucoseDataResponse {
            var sensorIdLength = Int(data[Offset.SENSOR_ID_LENGTH])
            if sensorIdLength == 0x00 {
                // value fetched during GetSensorInformation
                sensorIdLength = Eversense365.sensorIdLength
            }

            return GetGlucoseDataResponse(
                trend: getTrend(value: data[Offset.TREND_DIRECTION + sensorIdLength]),
                glucoseDatetime: Date.fromUnix2000(
                    data: data
                        .subdata(
                            in: (Offset.GLUCOSE_DATETIME_START + sensorIdLength) ..<
                                (Offset.GLUCOSE_DATETIME_END + sensorIdLength)
                        )
                ),
                glucoseInMgDl: UInt16(data[Offset.GLUCOSE + sensorIdLength]) |
                    (UInt16(data[Offset.GLUCOSE + sensorIdLength + 1]) << 8),
                raw: "0x" + data.subdata(in: 0 ..< 193).hexString(),
                sensorId: Data(data.subdata(in: Offset.SENSOR_ID ..< Offset.SENSOR_ID + sensorIdLength))
            )
        }

        func getTrend(value: UInt8) -> GlucoseTrend {
            switch value {
            case 0:
                return .flat // STALE
            case 1:
                return .downDown
            case 2:
                return .down
            case 4:
                return .flat
            case 8:
                return .up
            case 16:
                return .upUp
            case 32:
                return .downDownDown
            case 64:
                return .upUpUp
            default:
                return .flat // STALE
            }
        }

        enum Offset {
            static let CURRENT_DATETIME_START = 2
            static let CURRENT_DATETIME_END = 10

            static let SENSOR_TYPE = 10
            static let SENSOR_ID_LENGTH = 11
            static let SENSOR_ID = 11

            static let GLUCOSE_DATETIME_START = 12
            static let GLUCOSE_DATETIME_END = 20

            static let GLUCOSE = 20
            static let SIGNAL_STRENGTH = 22
            static let GLUCOSE_UNAVAILABLE = 24

            static let MEASUREMENT_START = 26
            static let MEASUREMENT_END = 162

            static let TREND_VALUE = 162
            static let TREND_DIRECTION = 164
            static let SENSOR_TEMPERATURE = 165
            static let MSP = 169
            static let MEP_SPIKE = 173
            static let MEP_LOW_REF = 177
            static let MEP_DRIFT = 181
            static let MEP_REF_CHANNEL = 185
            static let MEP_VALUE = 189
            static let BATTERY_PERCENTAGE = 193
            static let TRANSMITTER_TEMPERATURE = 194
            static let ACCELEROMETER_X_AXIS = 198
            static let ACCELEROMETER_Y_AXIS = 202
            static let ACCELEROMETER_Z_AXIS = 206
        }
    }
}
