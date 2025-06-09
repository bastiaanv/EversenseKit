struct SecureKeyResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case Status
        case Result
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(String.self, forKey: .Status)
        result = try container.decode(SecureKeyResult.self, forKey: .Result)
    }

    let status: String
    let result: SecureKeyResult
}

struct SecureKeyResult: Decodable {
    enum CodingKeys: String, CodingKey {
        case Certificate
        case Digital_Signature
        case IsKeyAvailable
        case KpAuthKey
        case KpTxId
        case KpTxUniqueId
        case tx_flag
        case TxFleetKey
        case TxKeyVersion
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        certificate = try container.decodeIfPresent(String.self, forKey: .Certificate)
        digitalSignature = try container.decodeIfPresent(String.self, forKey: .Digital_Signature)
        isKeyAvailable = try container.decode(Bool.self, forKey: .IsKeyAvailable)
        kpAuthKey = try container.decodeIfPresent(String.self, forKey: .KpAuthKey)
        kpTxId = try container.decodeIfPresent(String.self, forKey: .KpTxId)
        kpTxUniqueId = try container.decodeIfPresent(String.self, forKey: .KpTxUniqueId)
        txFlag = try container.decodeIfPresent(Bool.self, forKey: .tx_flag)
        txFleetKey = try container.decode(String.self, forKey: .TxFleetKey)
        txKeyVersion = try container.decodeIfPresent(String.self, forKey: .TxKeyVersion)
    }

    let certificate: String?
    let digitalSignature: String?
    let isKeyAvailable: Bool
    let kpAuthKey: String?
    let kpTxId: String?
    let kpTxUniqueId: String?
    let txFlag: Bool?
    let txFleetKey: String
    let txKeyVersion: String?
}
