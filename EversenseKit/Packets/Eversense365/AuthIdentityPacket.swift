extension Eversense365 {
    class AuthIdentityResponse {}

    class AuthIdentityPacket: BasePacket {
        typealias T = AuthIdentityResponse

        var responseType: UInt8 {
            PacketIds.AuthenticateV2ResponseId.rawValue
        }

        var responseId: UInt8? {
            AuthTypes.AuthenticateV2Identity.rawValue
        }

        let secret: Data
        init(secret: Data) {
            self.secret = secret
        }

        func getRequestData() -> Data {
            var data = Data([PacketIds.AuthenticateV2CommandId.rawValue, AuthTypes.AuthenticateV2Identity.rawValue])
            data.append(secret)

            return data
        }

        func parseResponse(data _: Data) -> AuthIdentityResponse {
            AuthIdentityResponse()
        }
    }
}
