//
//  GetMmaFeaturesPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 15/05/2025.
//

struct GetMmaFeaturesPacketResponse {
    let value: UInt8
}

class GetMmaFeaturesPacket : BasePacket {
    typealias T = GetMmaFeaturesPacketResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.mmaFeaturesAddress)
    }
    
    func parseResponse(data: Data) -> GetMmaFeaturesPacketResponse {
        return GetMmaFeaturesPacketResponse(value: data[0])
    }
}
