extension Eversense365 {
    class PingResponse {}

    class PingPacket: BasePacket {
        typealias T = PingResponse

        var response: PacketIds {
            PacketIds.pingResponseId
        }

        func getRequestData() -> Data {
            let data = Data([0x01])

            return CryptoUtil.shared.encrypt(data: data)
        }

        func parseResponse(data _: Data) -> PingResponse {
            PingResponse()
        }
    }
}
