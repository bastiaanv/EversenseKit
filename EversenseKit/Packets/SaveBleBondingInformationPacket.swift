//
//  SaveBleBondingInformationPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 13/05/2025.
//

struct SaveBleBondingInformationPacketResponse {}

class SaveBleBondingInformationPacket : BasePacket {
    typealias T = SaveBleBondingInformationPacketResponse
    
    var response: PacketIds {
        PacketIds.saveBLEBondingInformationResponseId
    }
    
    func getRequestData() -> Data {
        var data = Data([PacketIds.saveBLEBondingInformationCommandId.rawValue])
        let checksum = BinaryOperations.dataFrom16Bits(value: BinaryOperations.generateChecksumCRC16(data: data))
        data.append(checksum)
        
        return data
    }
    
    func parseResponse(data: Data) -> SaveBleBondingInformationPacketResponse {
        return SaveBleBondingInformationPacketResponse()
    }
    
    
}
