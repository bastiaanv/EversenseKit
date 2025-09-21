extension EversenseE3 {
    class GetLowGlucoseAlarmResponse {
        let valueInMgDl: UInt16

        init(valueInMgDl: UInt16) {
            self.valueInMgDl = valueInMgDl
        }
    }

    class GetLowGlucoseAlarmPacket: BasePacket {
        typealias T = GetLowGlucoseAlarmResponse

        var responseType: UInt8 {
            PacketIds.readTwoByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.lowGlucoseAlarmThreshold)
        }

        func parseResponse(data: Data) -> GetLowGlucoseAlarmResponse {
            GetLowGlucoseAlarmResponse(
                valueInMgDl: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
            )
        }
    }
}
