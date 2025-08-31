extension EversenseE3 {
    class SetLowGlucoseAlarmResponse {}

    class SetLowGlucoseAlarmPacket: BasePacket {
        typealias T = SetLowGlucoseAlarmResponse

        var response: PacketIds {
            PacketIds.readTwoByteSerialFlashRegisterResponseId
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
