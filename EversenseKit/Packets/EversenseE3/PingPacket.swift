extension EversenseE3 {
    class PingResponse {}

    class PingPacket: BasePacket {
        typealias T = PingResponse

        var responseType: UInt8 {
            PacketIds.pingResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
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
}
