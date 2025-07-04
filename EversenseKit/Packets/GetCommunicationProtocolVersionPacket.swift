class GetCommunicationProtocolVersionResponse {
    let version: String

    init(version: String) {
        self.version = version
    }
}

class GetCommunicationProtocolVersionPacket: BasePacket {
    typealias T = GetCommunicationProtocolVersionResponse

    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.communicationProtocolVersion)
    }

    func parseResponse(data: Data) -> GetCommunicationProtocolVersionResponse {
        let version = data[start ..< start + 4].compactMap { String(UnicodeScalar($0)) }.joined()
        return GetCommunicationProtocolVersionResponse(version: version)
    }
}
