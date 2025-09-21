extension EversenseE3 {
    class SetAppVersionResponse {}

    class SetAppVersionPacket: BasePacket {
        typealias T = SetAppVersionResponse

        private let appVersion: Data
        var responseType: UInt8 {
            PacketIds.writeFourByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        init(appVersion: Data) {
            self.appVersion = appVersion
        }

        func getRequestData() -> Data {
            CommandOperations.writeFourByteSerialFlashRegister(memoryAddress: FlashMemory.appVersion, data: appVersion)
        }

        func parseResponse(data _: Data) -> SetAppVersionResponse {
            SetAppVersionResponse()
        }

        public static func parseAppVersion(version: String) -> Data? {
            let splitted = version.split(separator: ".")
            guard let i0 = Int(splitted[0]), let i1 = Int(splitted[1]), let i2 = Int(splitted[2]) else {
                return nil
            }

            return Data([
                UInt8(i2),
                UInt8((i2 & 0xFF00) >> 8),
                UInt8(i1),
                UInt8(i0)
            ])
        }
    }
}
