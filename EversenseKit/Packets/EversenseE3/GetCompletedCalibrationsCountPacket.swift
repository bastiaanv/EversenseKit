extension EversenseE3 {
    class GetCompletedCalibrationsCountResponse {
        let value: UInt16

        init(value: UInt16) {
            self.value = value
        }
    }

    class GetCompletedCalibrationsCountPacket: BasePacket {
        typealias T = GetCompletedCalibrationsCountResponse

        var responseType: UInt8 {
            PacketIds.readTwoByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.calibrationsMadeInThisPhase)
        }

        func parseResponse(data: Data) -> GetCompletedCalibrationsCountResponse {
            GetCompletedCalibrationsCountResponse(
                value: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
            )
        }
    }
}
