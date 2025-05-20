//
//  GetMmaFeaturesPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 15/05/2025.
//

struct GetMmaFeaturesResponse {
    let value: UInt8
}

class GetMmaFeaturesPacket : BasePacket {
    typealias T = GetMmaFeaturesResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.mmaFeatures)
    }
    
    func parseResponse(data: Data) -> GetMmaFeaturesResponse {
        return GetMmaFeaturesResponse(
            value: data[start]
        )
    }
}
