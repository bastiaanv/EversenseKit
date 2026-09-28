extension Eversense365 {
    class SetHighGlucoseAlarmResponse {}

    class SetHighGlucoseAlarmPacket: BasePacket {
        typealias T = SetHighGlucoseAlarmResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.HighGlucoseAlarm.rawValue
        }

        let value: UInt16
        init(value: UInt16) {
            self.value = value
        }

        func getRequestData() -> Data {
            var data = Data([PacketIds.WriteCommandId.rawValue, WriteIds.HighGlucoseAlarm.rawValue])
            data.append(BinaryOperations.dataFrom16Bits(value: value))

            return data
        }

        func parseResponse(data _: Data) -> SetHighGlucoseAlarmResponse {
            SetHighGlucoseAlarmResponse()
        }
    }
}
