//
//  SecureKeyResponse.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 01/06/2025.
//

struct SecureKeyResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case Status
        case Result
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(String.self, forKey: .Status)
        self.result = try container.decode(SecureKeyResult.self, forKey: .Result)
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
        self.certificate = try container.decodeIfPresent(String.self, forKey: .Certificate)
        self.digitalSignature = try container.decodeIfPresent(String.self, forKey: .Digital_Signature)
        self.isKeyAvailable = try container.decode(Bool.self, forKey: .IsKeyAvailable)
        self.kpAuthKey = try container.decodeIfPresent(String.self, forKey: .KpAuthKey)
        self.kpTxId = try container.decodeIfPresent(String.self, forKey: .KpTxId)
        self.kpTxUniqueId = try container.decodeIfPresent(String.self, forKey: .KpTxUniqueId)
        self.txFlag = try container.decodeIfPresent(Bool.self, forKey: .tx_flag)
        self.txFleetKey = try container.decode(String.self, forKey: .TxFleetKey)
        self.txKeyVersion = try container.decodeIfPresent(String.self, forKey: .TxKeyVersion)
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
