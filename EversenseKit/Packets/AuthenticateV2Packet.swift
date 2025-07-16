class AuthenticateV2Response {
    var status: UInt8 = 0
    var nonce = Data()
    var serialNumber = Data()
    var flags: Bool = false

    init(nonce: Data, serialNumber: Data, flags: Bool) {
        self.nonce = nonce
        self.serialNumber = serialNumber
        self.flags = flags
    }

    init(status: UInt8) {
        self.status = status
    }
}

enum AuthType: UInt8 {
    case WhoAmI = 1
    case Identity = 2
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
        print("AuthV2 response: \(data.hexString())")

        if data[1] == 0x01 {
            // WhoAmI response
            let serialNumberData = data.subdata(in: 2 ..< 34)
            let nonce = data.subdata(in: 34 ..< 42)

            // 0B0133303633363600000000000000000000000000000000000000000000000000004CFC914E088197B20100
            // https://deviceauthorization.eversensedms.com/api/vault/GetTxCertificate?tx_flags=false&txSerialNumber=MzA2MzY2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA&nonce=A2FHViKll8g&clientType=128&clientNo=1&kp_client_unique_id=4mi93BpYpxivRiUHGWWpMDX7UjE7lCpB4YhFFHEebe4ulBMjALegv5dm5RSsc3wrj2Ddc5P6Ffs-qiWCtz3L5Q
            print(
                "AuthV2 response - nonce: \(nonce.hexString()), serialNumber: \(serialNumberData.hexString()), flags: \((UInt16(data[43]) << 8) | UInt16(data[42]))"
            )

            return AuthenticateV2Response(
                nonce: nonce,
                serialNumber: serialNumberData,
                flags: ((UInt16(data[43]) << 8) | UInt16(data[42]) & 0x0F) == 0
            )
        } else {
            return AuthenticateV2Response(
                status: data[2]
            )
        }
    }
}
