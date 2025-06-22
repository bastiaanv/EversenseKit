//
//  Authenticatev1Packet.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 22/06/2025.
//

import Crypto

struct Authenticatev1Response {}

class Authenticatev1Packet : BasePacket {
    typealias T = Authenticatev1Response
    
    var response: PacketIds {
        PacketIds.authenticateResponseId
    }
    
    private let sessionKey: SymmetricKey
    private let salt: Data
    init(sessionKey: SymmetricKey, salt: Data) {
        self.sessionKey = sessionKey
        self.salt = salt
    }
    
    func getRequestData() -> Data {
        var data = Data([PacketIds.authenticateCommandId.rawValue, 0x02, 0x80, 0x00])
        data.append(salt)

        let signature = CryptoUtil.generateSignature(sessionKey: sessionKey, data: data)
        data.append(signature)

        return EncodingOperations.encode(data: data)
    }
    
    func parseResponse(data: Data) -> Authenticatev1Response {
        return Authenticatev1Response()
    }
    
    func checkHmac(data: Data) -> Bool {
        let generatedSignature = CryptoUtil.generateSignature(sessionKey: sessionKey, data: data.subdata(in: 0..<data.count-8))
        return equals(generatedSignature, data.subdata(in: data.count-8..<data.count))
    }
    
    private func equals(_ data1: Data, _ data2: Data) -> Bool {
        guard data1.count == data2.count else {
            return false
        }

        var result: Int = 0
        for i in 0..<data1.count {
            result |= Int(data1[i]) ^ Int(data2[i])
        }

        return result == 0
    }
}
