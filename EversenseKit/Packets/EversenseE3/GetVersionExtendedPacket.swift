extension EversenseE3 {
    class GetVersionExtendedResponse {
        let extVersion: String

        init(extVersion: String) {
            self.extVersion = extVersion
        }
    }

    class GetVersionExtendedPacket: BasePacket {
        typealias T = GetVersionExtendedResponse

        var responseType: UInt8 {
            PacketIds.readFourByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.transmitterSoftwareVersionExt)
        }

        func parseResponse(data: Data) -> GetVersionExtendedResponse {
            let extVersion = data[start ..< start + 4].compactMap { String(UnicodeScalar($0)) }.joined()
            return GetVersionExtendedResponse(extVersion: extVersion)
        }
    }
}
