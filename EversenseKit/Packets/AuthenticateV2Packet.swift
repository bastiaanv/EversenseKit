class AuthenticateV2Response {
    let nonce: String
    let serialNumber: String
    let flags: Bool

    init(nonce: String, serialNumber: String, flags: Bool) {
        self.nonce = nonce
        self.serialNumber = serialNumber
        self.flags = flags
    }
}

// WhoAmI packet
class AuthenticateV2Packet: BasePacket {
    typealias T = AuthenticateV2Response

    var response: PacketIds {
        PacketIds.authenticateV2ResponseId
    }

    let clientId: Data
    init(clientId: Data) {
        self.clientId = clientId
    }

    func getRequestData() -> Data {
        var data = Data([PacketIds.authenticateV2CommandId.rawValue, 1])
        data.append(clientId)

        return data
    }

    func parseResponse(data: Data) -> AuthenticateV2Response {
        let accessTokenData = data.subdata(in: 1 ..< 33)
        let serialNumberData = data.subdata(in: 33 ..< 41)

        return AuthenticateV2Response(
            nonce: accessTokenData.base64EncodedString(),
            serialNumber: serialNumberData.base64EncodedString(),
            flags: (UInt16(data[42]) << 8) | UInt16(data[43]) != 0
        )
    }
}
