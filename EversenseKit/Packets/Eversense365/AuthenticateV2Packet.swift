extension Eversense365 {
    class AuthenticateV2Response {
        var status: UInt8 = 0
        var length: Int = 0
        var nonce = Data()
        var serialNumber = Data()
        var flags: Bool = false
        var sessionPublicKey = Data()

        init(nonce: Data, serialNumber: Data, flags: Bool) {
            self.nonce = nonce
            self.serialNumber = serialNumber
            self.flags = flags
        }

        init(status: UInt8) {
            self.status = status
        }

        init(length: Int, sessionPublicKey: Data) {
            self.length = length
            self.sessionPublicKey = sessionPublicKey
        }
    }

    enum AuthType: UInt8 {
        case WhoAmI = 1
        case Identity = 2
        case Start = 3
    }

    class AuthenticateV2Packet: BasePacket {
        typealias T = AuthenticateV2Response

        var response: PacketIds {
            PacketIds.authenticateV2ResponseId
        }

        let type: AuthType
        let secret: Data
        init(type: AuthType, secret: Data) {
            self.type = type
            self.secret = secret
        }

        func getRequestData() -> Data {
            var data = Data([PacketIds.authenticateV2CommandId.rawValue, type.rawValue])
            data.append(secret)

            return data
        }

        func parseResponse(data: Data) -> AuthenticateV2Response {
            if data[1] == 0x01 {
                // WhoAmI response
                let serialNumberData = data.subdata(in: 2 ..< 34)
                let nonce = data.subdata(in: 34 ..< 42)

                return AuthenticateV2Response(
                    nonce: nonce,
                    serialNumber: serialNumberData,
                    flags: ((UInt16(data[43]) << 8) | UInt16(data[42]) & 0x0F) == 0
                )
            } else if data[1] == 0x02 {
                return AuthenticateV2Response(
                    status: 0
                )
            } else if data[1] == 0x03 {
                let sessionPublicKeyData = data.subdata(in: 2 ..< 66)
                return AuthenticateV2Response(
                    length: data.count,
                    sessionPublicKey: sessionPublicKeyData
                )
            } else {
                return AuthenticateV2Response(
                    status: data[2]
                )
            }
        }
    }
}
