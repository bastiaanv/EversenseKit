//
//  SaveBleBondingInformationPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 13/05/2025.
//

struct SaveBleBondingInformationResponse {}

class SaveBleBondingInformationPacket : BasePacket {
    typealias T = SaveBleBondingInformationResponse
    
    var response: PacketIds {
        PacketIds.saveBLEBondingInformationResponseId
    }
    
    func getRequestData() -> Data {
        var data = Data([PacketIds.saveBLEBondingInformationCommandId.rawValue])
        let checksum = BinaryOperations.dataFrom16Bits(value: BinaryOperations.generateChecksumCRC16(data: data))
        data.append(checksum)
        
        return data
    }
    
    func parseResponse(data: Data) -> SaveBleBondingInformationResponse {
        return SaveBleBondingInformationResponse()
    }
    
    
}
