//
//  GetModelPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetModelResponse {
    let model: String
}

class GetModelPacket : BasePacket {
    typealias T = GetModelResponse
    
    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.transmitterModelNumber)
    }
    
    func parseResponse(data: Data) -> GetModelResponse {
        return GetModelResponse(
            model: "\(UInt32(data[start]) | (UInt32(data[start+1]) << 8) | (UInt32(data[start+2]) << 16) | (UInt32(data[start+3]) << 24))"
        )
    }
}
