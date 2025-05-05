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
            model: "\(data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24))"
        )
    }
}
