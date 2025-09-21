extension Eversense365 {
    class PingResponse {}

    class PingPacket: BasePacket {
        typealias T = PingResponse

        var responseType: UInt8 {
            PacketIds.ReadResponseId.rawValue
        }

        var responseId: UInt8? {
            ReadIds.Ping.rawValue
        }

        func getRequestData() -> Data {
            let data = Data([PacketIds.ReadCommandId.rawValue, ReadIds.Ping.rawValue])
            return CryptoUtil.shared.encrypt(data: data)
        }

        func parseResponse(data _: Data) -> PingResponse {
            PingResponse()
        }
    }
}
