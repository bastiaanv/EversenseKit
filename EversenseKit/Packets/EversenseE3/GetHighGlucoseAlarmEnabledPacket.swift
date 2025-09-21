extension EversenseE3 {
    class GetHighGlucoseAlarmEnabledResponse {
        let value: Bool

        init(value: Bool) {
            self.value = value
        }
    }

    class GetHighGlucoseAlarmEnabledPacket: BasePacket {
        typealias T = GetHighGlucoseAlarmEnabledResponse

        var responseType: UInt8 {
            PacketIds.readSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.highGlucoseAlarmEnabled)
        }

        func parseResponse(data: Data) -> GetHighGlucoseAlarmEnabledResponse {
            GetHighGlucoseAlarmEnabledResponse(
                value: data[start] == 0x55
            )
        }
    }
}
