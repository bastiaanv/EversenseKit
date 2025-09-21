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
            ReadIds.GetSignalStrength.rawValue
        }

        func getRequestData() -> Data {
            let data = Data([PacketIds.ReadCommandId.rawValue, ReadIds.GetSignalStrength.rawValue])
            return CryptoUtil.shared.encrypt(data: data)
        }

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
