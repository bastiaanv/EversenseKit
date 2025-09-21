extension Eversense365 {
    class GetSensorInformationResponse {
        let serialNumber: String
        let transmitterName: String
        let transmitterDatetime: Date
        let mmaFeatures: UInt8
        let batteryLevel: Int

        init(serialNumber: String, transmitterName: String, transmitterDatetime: Date, mmaFeatures: UInt8, batteryLevel: Int) {
            self.serialNumber = serialNumber
            self.transmitterName = transmitterName
            self.transmitterDatetime = transmitterDatetime
            self.mmaFeatures = mmaFeatures
            self.batteryLevel = batteryLevel
        }
    }

    class GetSensorInformationPacket: BasePacket {
        typealias T = GetSensorInformationResponse

        var responseType: UInt8 {
            PacketIds.ReadResponseId.rawValue
        }

        var responseId: UInt8? {
            ReadIds.GetSensorInformation.rawValue
        }

        func getRequestData() -> Data {
            let data = Data([PacketIds.ReadCommandId.rawValue, ReadIds.GetSensorInformation.rawValue])
            return CryptoUtil.shared.encrypt(data: data)
        }

        func parseResponse(data: Data) -> Eversense365.GetSensorInformationResponse {
            let doubleSensorIdLen = Int(data[Offset.SENSOR_ID_LEN_START] * 2)

            return GetSensorInformationResponse(
                serialNumber: data
                    .subdata(in: Offset.SERIAL_NUMBER_START ..< Offset.SERIAL_NUMBER_END)
                    .toUtf8String(),
                transmitterName: data
                    .subdata(in: Offset.TRANSMITTER_NAME_START ..< Offset.TRANSMITTER_NAME_END)
                    .toUtf8String(),
                transmitterDatetime: Date
                    .fromUnix2000(data: data.subdata(in: Offset.CURRENT_DATETIME_START ..< Offset.CURRENT_DATETIME_END)),
                mmaFeatures: data[Offset.MMA_FUNCTIONALITY_START],
                batteryLevel: Int(data[Offset.BATTERY_PERCENTAGE_START + doubleSensorIdLen])
            )
        }

        enum Offset {
            static let SERIAL_NUMBER_START = 2
            static let SERIAL_NUMBER_END = 18

            static let TRANSMITTER_NAME_START = 18
            static let TRANSMITTER_NAME_END = 43

            static let CURRENT_DATETIME_START = 43
            static let CURRENT_DATETIME_END = 51

            static let TRANSMITTER_MODEL_START = 51
            static let TRANSMITTER_MODEL_END = 55

            static let CURRENT_FIRMWARE_VERSION_START = 55
            static let CURRENT_FIRMWARE_VERSION_END = 69

            static let COMM_VERSION_START = 69
            static let COMM_VERSION_END = 75

            static let REGISTER_MAP_VERSION_START = 75
            static let REGISTER_MAP_VERSION_END = 81

            static let LOG_MAP_VERSION_START = 81
            static let LOG_MAP_VERSION_END = 87

            static let PUSH_MAP_VERSION_START = 87
            static let PUSH_MAP_VERSION_END = 93

            static let GLUCOSE_ALGORITHM_MAJOR_START = 93
            static let GLUCOSE_ALGORITHM_MAJOR_END = 94

            static let GLUCOSE_ALGORITHM_MINOR_START = 94
            static let GLUCOSE_ALGORITHM_MINOR_END = 95

            static let MMA_FUNCTIONALITY_START = 95
            static let MMA_FUNCTIONALITY_END = 96

            static let TRANSMITTER_MODE_START = 96
            static let TRANSMITTER_MODE_END = 98

            static let TRANSMITTER_LIFE_REMAINING_START = 98
            static let TRANSMITTER_LIFE_REMAINING_END = 100

            static let SAMPLE_INTERVAL_START = 100
            static let SAMPLE_INTERVAL_END = 102

            static let SENSOR_TYPE_START = 102
            static let SENSOR_TYPE_END = 103

            static let SENSOR_ID_LEN_START = 103
            static let SENSOR_ID_LEN_END = 104

            // From here on, add the value from SENSOR_ID_LEN to these values
            static let SENSOR_ID_START = 104
            static let SENSOR_ID_END = 104

            static let INSERTION_DATE_START = 104
            static let INSERTION_DATE_END = 112

            static let SENSOR_LIFE_REMAINING_START = 112
            static let SENSOR_LIFE_REMAINING_END = 114

            // Double the SENSOR_ID_LEN value from here...
            static let DETECTED_SENSOR_ID_START = 114
            static let DETECTED_SENSOR_ID_END = 114

            static let BATTERY_PERCENTAGE_START = 114
            static let BATTERY_PERCENTAGE_END = 115

            static let FIRMWARE_VERSION_START = 115
            static let FIRMWARE_VERSION_END = 131

            static let OPERATION_START_DATE_START = 131
            static let OPERATION_START_DATE_END = 139

            static let OTHER_FIRMWARE_VERSION_START = 139
            static let OTHER_FIRMWARE_VERSION_END = 155
        }
    }
}
