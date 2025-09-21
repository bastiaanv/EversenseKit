extension Eversense365 {
    class SetCurrentDateTimeResponse {}

    class SetCurrentDateTimePacket: BasePacket {
        typealias T = SetCurrentDateTimeResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.CurrentDateTime.rawValue
        }

        func getRequestData() -> Data {
            var data = Data([PacketIds.WriteCommandId.rawValue, WriteIds.CurrentDateTime.rawValue])

            data.append(Date().toUnix2000())
            data.append(BinaryOperations.toTimeZoneArray())
            data.append(TimeZone.current.secondsFromGMT() >= 0 ? 0 : 255)

            return CryptoUtil.shared.encrypt(data: data)
        }

        func parseResponse(data _: Data) -> Eversense365.SetCurrentDateTimeResponse {
            SetCurrentDateTimeResponse()
        }
    }
}
