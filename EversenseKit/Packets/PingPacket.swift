struct PingResponse {}

class PingPacket: BasePacket {
    typealias T = PingResponse

    var response: PacketIds {
        PacketIds.pingResponseId
    }

    func getRequestData() -> Data {
        var data = Data([0x01])

        let checksum = BinaryOperations.generateChecksumCRC16(data: data)
        data.append(BinaryOperations.dataFrom16Bits(value: checksum))

        return data
    }

    func parseResponse(data _: Data) -> PingResponse {
        PingResponse()
    }
}
