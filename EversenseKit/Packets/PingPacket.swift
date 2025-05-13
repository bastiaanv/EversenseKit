//
//  PingPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct PingPacketResponse {}

class PingPacket : BasePacket {
    typealias T = PingPacketResponse
    
    static var response: PacketIds {
        PacketIds.pingResponseId
    }
    
    func getRequestData() -> Data {
        var data = Data([0x01])
        
        let checksum = BinaryOperations.generateChecksumCRC16(data: data)
        data.append(BinaryOperations.dataFrom16Bits(value: checksum))
        
        return data
    }
    
    static func parseResponse(data: Data) -> PingPacketResponse {
        return PingPacketResponse()
    }
}
