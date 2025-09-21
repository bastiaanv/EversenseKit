extension EversenseE3 {
    class SetHighGlucoseAlarmResponse {}

    class SetHighGlucoseAlarmPacket: BasePacket {
        typealias T = SetHighGlucoseAlarmResponse

        var responseType: UInt8 {
            PacketIds.writeTwoByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        let value: UInt16
        init(value: UInt16) {
            self.value = value
        }

        func getRequestData() -> Data {
            let data = BinaryOperations.dataFrom16Bits(value: value)
            return CommandOperations.writeTwoByteSerialFlashRegister(
                memoryAddress: FlashMemory.highGlucoseAlarmThreshold,
                data: data
            )
        }

        func parseResponse(data _: Data) -> SetHighGlucoseAlarmResponse {
            SetHighGlucoseAlarmResponse()
        }
    }
}
