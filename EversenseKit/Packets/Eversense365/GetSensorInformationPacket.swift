extension Eversense365 {
    class GetSensorInformationResponse {
        let serialNumber: String
        let transmitterName: String
        let transmitterDatetime: Date
        let insertionDate: Date
        let mmaFeatures: UInt8
        let batteryLevel: Int
        let version: String
        let extVersion: String
        let sensorIdLength: Int
        let sensorId: Data
        let communicationProtocolVersion: Double

        init(
            serialNumber: String,
            transmitterName: String,
            transmitterDatetime: Date,
            insertionDate: Date,
            mmaFeatures: UInt8,
            batteryLevel: Int,
            version: String,
            extVersion: String,
            sensorIdLength: Int,
            sensorId: Data,
            communicationProtocolVersion: Double
        ) {
            self.serialNumber = serialNumber
            self.transmitterName = transmitterName
            self.transmitterDatetime = transmitterDatetime
            self.insertionDate = insertionDate
            self.mmaFeatures = mmaFeatures
            self.batteryLevel = batteryLevel
            self.version = version
            self.extVersion = extVersion
            self.sensorIdLength = sensorIdLength
            self.sensorId = sensorId
            self.communicationProtocolVersion = communicationProtocolVersion
        }
    }

    class GetSensorInformationPacket: BasePacket {
        typealias T = GetSensorInformationResponse

        var responseType: UInt8 {
            PacketIds.ReadResponseId.rawValue
        }

        var responseId: UInt8? {
            ReadIds.SensorInformation.rawValue
        }

        func getRequestData() -> Data {
            Data([PacketIds.ReadCommandId.rawValue, ReadIds.SensorInformation.rawValue])
        }

        /// Message parsed:
        /// 42 20 -> CmdType & CmdId
        /// 33 30 36 33 36 36 00 00 00 00 00 00 00 00 00 00 -> Serial number
        /// 44 33 30 36 33 36 36 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 -> Transmitter name
        /// 1A 44 08 CB BF 00 00 00 -> Current datetime
        /// 29 6D 23 06 -> Transmitter model
        /// 30 35 2E 30 30 2E 30 31 2E 30 37 4D 00 00 -> Current firmware version
        /// 30 31 2E 30 36 00 -> Comm version
        /// 30 31 2E 30 30 00 -> Register map version
        /// 30 31 2E 30 30 00 -> Log map version
        /// 30 31 2E 30 30 00 -> Push map version
        /// 00 -> Glucose algorithm version major
        /// 00 -> Glucose algorithm version minor
        /// 01 -> MMA functionality
        /// 11 00 -> Transmitter mode
        /// 8C 01 -> Transmitter life remaining
        /// 2C 01 -> Sensor sample interval
        /// 01 -> Sensor type
        /// 0A -> Sensor ID length
        /// 00 00 00 00 00 00 00 00 00 00 -> Sensor ID (size is based on previous value)
        /// 00 00 00 00 00 00 00 00 -> Sensor insertion date
        /// 00 00 -> Sensor life remaining
        /// 00 00 00 00 00 00 00 00 00 00 -> Detected sensor ID (length is based on Sensor ID length)
        /// 62 -> Battery percentage
        /// 30 35 2E 30 30 2E 30 31 2E 30 37 4D 2D 30 36 00 -> Firmware version
        /// 00 00 00 00 00 00 00 00 -> Operation start datetime
        /// 30 31 2E 30 30 2E 30 31 2E 30 32 00 00 00 00 00 -> Other firmware version
        func parseResponse(data: Data) -> Eversense365.GetSensorInformationResponse {
            let sensorIdLen = Int(data[Offset.SENSOR_ID_LEN_START])
            let doubleSensorIdLen = sensorIdLen * 2

            return GetSensorInformationResponse(
                serialNumber: data
                    .subdata(in: Offset.SERIAL_NUMBER_START ..< Offset.SERIAL_NUMBER_END)
                    .toUtf8String(),
                transmitterName: data
                    .subdata(in: Offset.TRANSMITTER_NAME_START ..< Offset.TRANSMITTER_NAME_END)
                    .toUtf8String(),
                transmitterDatetime: Date
                    .fromUnix2000(data: data.subdata(in: Offset.CURRENT_DATETIME_START ..< Offset.CURRENT_DATETIME_END)),
                insertionDate: Date
                    .fromUnix2000(
                        data: data
                            .subdata(in: Offset.INSERTION_DATE_START + sensorIdLen ..< Offset.INSERTION_DATE_END + sensorIdLen)
                    ),
                mmaFeatures: data[Offset.MMA_FUNCTIONALITY_START],
                batteryLevel: Int(data[Offset.BATTERY_PERCENTAGE_START + doubleSensorIdLen]),
                version: data
                    .subdata(
                        in: Offset.FIRMWARE_VERSION_START + doubleSensorIdLen ..< Offset
                            .FIRMWARE_VERSION_END + doubleSensorIdLen
                    )
                    .toUtf8String(),
                extVersion: data
                    .subdata(
                        in: Offset.OTHER_FIRMWARE_VERSION_START + doubleSensorIdLen ..< Offset
                            .OTHER_FIRMWARE_VERSION_END + doubleSensorIdLen
                    )
                    .toUtf8String(),
                sensorIdLength: sensorIdLen,
                sensorId: Data(data.subdata(in: Offset.SENSOR_ID_START ..< Offset.SENSOR_ID_END + sensorIdLen - 2).reversed()),
                communicationProtocolVersion: Double(
                    data.subdata(in: Offset.COMM_VERSION_START ..< Offset.COMM_VERSION_END).toUtf8String()
                ) ?? 0
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
