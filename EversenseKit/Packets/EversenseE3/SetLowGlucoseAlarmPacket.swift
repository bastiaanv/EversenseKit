extension EversenseE3 {
    class SetLowGlucoseAlarmResponse {}

    class SetLowGlucoseAlarmPacket: BasePacket {
        typealias T = SetLowGlucoseAlarmResponse

        var responseType: UInt8 {
            PacketIds.readTwoByteSerialFlashRegisterResponseId.rawValue
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
                memoryAddress: FlashMemory.lowGlucoseAlarmThreshold,
                data: data
            )
        }

        func parseResponse(data _: Data) -> SetLowGlucoseAlarmResponse {
            SetLowGlucoseAlarmResponse()
        }
    }
}
