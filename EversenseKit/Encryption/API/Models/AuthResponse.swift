struct AuthResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case expires
        case lastLogin
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        tokenType = try container.decode(String.self, forKey: .tokenType)
        expires = try container.decode(String.self, forKey: .expires)
        lastLogin = try container.decode(String.self, forKey: .lastLogin)
    }

    let accessToken: String
    let expiresIn: Int
    let tokenType: String
    let expires: String
    let lastLogin: String
}
