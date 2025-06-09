struct GetIsOneCalPhaseResponse {
    let value: Bool
}

class GetIsOneCalPhasePacket: BasePacket {
    typealias T = GetIsOneCalPhaseResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.isOneCalPhase)
    }

    func parseResponse(data: Data) -> GetIsOneCalPhaseResponse {
        GetIsOneCalPhaseResponse(
            value: data[start] == 1
        )
    }
}
