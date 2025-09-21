extension EversenseE3 {
    class GetHighGlucoseAlarmResponse {
        let valueInMgDl: UInt16

        init(valueInMgDl: UInt16) {
            self.valueInMgDl = valueInMgDl
        }
    }

    class GetHighGlucoseAlarmPacket: BasePacket {
        typealias T = GetHighGlucoseAlarmResponse

        var responseType: UInt8 {
            PacketIds.readTwoByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.highGlucoseAlarmThreshold)
        }

        func parseResponse(data: Data) -> GetHighGlucoseAlarmResponse {
            GetHighGlucoseAlarmResponse(
                valueInMgDl: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
            )
        }
    }
}
