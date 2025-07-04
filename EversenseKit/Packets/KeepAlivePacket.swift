class KeepAliveResponse {}

class KeepAlivePacket: BasePacket {
    typealias T = KeepAliveResponse

    var response: PacketIds {
        PacketIds.keepAlivePush
    }

    func getRequestData() -> Data {
        Data()
    }

    func parseResponse(data _: Data) -> KeepAliveResponse {
        KeepAliveResponse()
    }
}
