extension EversenseE3 {
    class GetRecentGlucoseValueResponse {
        let valueInMgDl: UInt16

        init(valueInMgDl: UInt16) {
            self.valueInMgDl = valueInMgDl
        }
    }

    class GetRecentGlucoseValuePacket: BasePacket {
        typealias T = GetRecentGlucoseValueResponse

        var responseType: UInt8 {
            PacketIds.readTwoByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentGlucoseValue)
        }

        func parseResponse(data: Data) -> GetRecentGlucoseValueResponse {
            GetRecentGlucoseValueResponse(
                valueInMgDl: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
            )
        }
    }
}
