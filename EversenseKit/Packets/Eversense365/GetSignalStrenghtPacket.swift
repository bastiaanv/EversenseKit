extension Eversense365 {
    class GetSignalStrenghtResponse {
        let rawValue: UInt16
        let signalStrength: SignalStrength

        init(rawValue: UInt16, signalStrength: SignalStrength) {
            self.rawValue = rawValue
            self.signalStrength = signalStrength
        }
    }

    class GetSignalStrenghtPacket: BasePacket {
        typealias T = GetSignalStrenghtResponse

        var responseType: UInt8 {
            PacketIds.ReadResponseId.rawValue
        }

        var responseId: UInt8? {
            ReadIds.SignalStrength.rawValue
        }

        func getRequestData() -> Data {
            Data([PacketIds.ReadCommandId.rawValue, ReadIds.SignalStrength.rawValue])
        }

        /// Message parsing:
        /// 42 1B -> CmdType & CmdId
        /// 01 -> SensorType
        /// 0A -> Sensor ID length
        /// 00 00 00 00 00 00 00 00 00 00 -> Sensor ID
        /// 86 2C 2E 02 00 00 00 00 -> Timestamp
        /// FF 07 -> Signal Strength
        /// 00 00 00 3F -> Signal Coupling
        /// 00 -> Placement
        ///
        /// 42 1b
        /// 01
        /// 0a
        /// 00 00 00 00 00 00 00 00 00 00
        /// 69 65 80 70 00 00 00 00
        /// fb 07
        /// 7c ee aa 3f
        /// 00
        func parseResponse(data: Data) -> Eversense365.GetSignalStrenghtResponse {
            let sensorIdLength = Int(data[Offset.SENSOR_ID_LEN_START])
            let signalCoupling = UInt32(
                data
                    .subdata(
                        in: (Offset.SIGNAL_COUPLING_START + sensorIdLength) ..<
                            (Offset.SIGNAL_COUPLING_END + sensorIdLength)
                    )
                    .toUInt64()
            )
            let actualSignalStrength = Int(Float(bitPattern: signalCoupling) * 100)

            return GetSignalStrenghtResponse(
                rawValue: UInt16(actualSignalStrength),
                signalStrength: SignalStrength.from365(value: actualSignalStrength)
            )
        }

        enum Offset {
            static let SENSOR_TYPE_START = 2
            static let SENSOR_TYPE_END = 3

            static let SENSOR_ID_LEN_START = 3
            static let SENSOR_ID_LEN_END = 4

            // Add SENSOR_ID_LEN to end from here on
            static let SENSOR_ID_START = 4
            static let SENSOR_ID_END = 4

            static let TIMESTAMP_START = 4
            static let TIMESTAMP_END = 12

            static let SIGNAL_STRENGTH_START = 12
            static let SIGNAL_STRENGTH_END = 14

            static let SIGNAL_COUPLING_START = 14
            static let SIGNAL_COUPLING_END = 18

            static let PLACEMENT_START = 18
            static let PLACEMENT_END = 19
        }
    }
}
