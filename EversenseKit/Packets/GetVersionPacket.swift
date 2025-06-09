struct GetVersionResponse {
    let version: String
}

class GetVersionPacket: BasePacket {
    typealias T = GetVersionResponse

    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.transmitterSoftwareVersion)
    }

    func parseResponse(data: Data) -> GetVersionResponse {
        let version = data[start ..< start + 4].compactMap { String(UnicodeScalar($0)) }.joined()
        return GetVersionResponse(version: version)
    }
}
