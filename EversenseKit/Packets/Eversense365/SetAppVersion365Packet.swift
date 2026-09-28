extension Eversense365 {
    class SetAppVersionResponse {}

    class SetAppVersionPacket: BasePacket {
        typealias T = SetAppVersionResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.AppVersion.rawValue
        }

        let maxLength = 18
        let appVersion: String
        init(appVersion: String) {
            self.appVersion = appVersion
        }

        func getRequestData() -> Data {
            var data = Data(count: maxLength)
            data[0] = PacketIds.WriteCommandId.rawValue
            data[1] = WriteIds.AppVersion.rawValue

            let appVersionData = appVersion.data(using: .ascii) ?? Data()
            var i = 2
            for char in appVersionData {
                data[i] = char
                i += 1
            }

            return data
        }

        /// Parsed message:
        /// 43 0E -> CmdType & CmdId
        func parseResponse(data _: Data) -> SetAppVersionResponse {
            SetAppVersionResponse()
        }
    }
}
