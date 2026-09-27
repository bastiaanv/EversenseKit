extension Eversense365 {
    class SetLowGlucoseAlarmResponse {}

    class SetLowGlucoseAlarmPacket: BasePacket {
        typealias T = SetLowGlucoseAlarmResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.LowGlucoseAlarm.rawValue
        }

        let value: UInt16
        init(value: UInt16) {
            self.value = value
        }

        func getRequestData() -> Data {
            var data = Data([PacketIds.WriteCommandId.rawValue, WriteIds.LowGlucoseAlarm.rawValue])
            data.append(BinaryOperations.dataFrom16Bits(value: value))

            return data
        }

        func parseResponse(data _: Data) -> SetLowGlucoseAlarmResponse {
            SetLowGlucoseAlarmResponse()
        }
    }
}
