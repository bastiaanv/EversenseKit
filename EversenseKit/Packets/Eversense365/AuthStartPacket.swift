extension Eversense365 {
    class AuthStartResponse {
        let sessionPublicKey: Data

        init(sessionPublicKey: Data) {
            self.sessionPublicKey = sessionPublicKey
        }
    }

    class AuthStartPacket: BasePacket {
        typealias T = AuthStartResponse

        var responseType: UInt8 {
            PacketIds.AuthenticateV2ResponseId.rawValue
        }

        var responseId: UInt8? {
            AuthTypes.AuthenticateV2Start.rawValue
        }

        let secret: Data
        init(
            clientId: Data,
            ephemPublicKey: Data,
            salt: Data,
            digitalSignature: Data
        ) {
            var startSecret = Data([128, 0])
            startSecret.append(clientId)
            startSecret.append(ephemPublicKey.subdata(in: 27 ..< ephemPublicKey.count))
            startSecret.append(salt)
            startSecret.append(digitalSignature)

            secret = startSecret
        }

        func getRequestData() -> Data {
            var data = Data([PacketIds.AuthenticateV2CommandId.rawValue, AuthTypes.AuthenticateV2Start.rawValue])
            data.append(secret)

            return data
        }

        func parseResponse(data: Data) -> AuthStartResponse {
            if data.count <= 7 {
                return AuthStartResponse(
                    sessionPublicKey: data
                )
            }

            return AuthStartResponse(
                sessionPublicKey: data.subdata(in: 2 ..< 66)
            )
        }
    }
}
