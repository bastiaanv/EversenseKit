extension EversenseE3 {
    class GetIsOneCalPhaseResponse {
        let value: Bool

        init(value: Bool) {
            self.value = value
        }
    }

    class GetIsOneCalPhasePacket: BasePacket {
        typealias T = GetIsOneCalPhaseResponse

        var responseType: UInt8 {
            PacketIds.readSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.isOneCalPhase)
        }

        func parseResponse(data: Data) -> GetIsOneCalPhaseResponse {
            GetIsOneCalPhaseResponse(
                value: data[start] == 0x55
            )
        }
    }
}
