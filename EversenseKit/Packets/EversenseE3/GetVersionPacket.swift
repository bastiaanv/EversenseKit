extension EversenseE3 {
    class GetVersionResponse {
        let version: String

        init(version: String) {
            self.version = version
        }
    }

    class GetVersionPacket: BasePacket {
        typealias T = GetVersionResponse

        var responseType: UInt8 {
            PacketIds.readFourByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.transmitterSoftwareVersion)
        }

        func parseResponse(data: Data) -> GetVersionResponse {
            let version = data[start ..< start + 4].compactMap { String(UnicodeScalar($0)) }.joined()
            return GetVersionResponse(version: version)
        }
    }
}
