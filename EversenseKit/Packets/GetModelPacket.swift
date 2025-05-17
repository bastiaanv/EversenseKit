//
//  GetModelPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetModelPacketResponse {
    let model: String
}

class GetModelPacket : BasePacket {
    typealias T = GetModelPacketResponse
    
    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.transmitterModelNumber)
    }
    
    func parseResponse(data: Data) -> GetModelPacketResponse {
        return GetModelPacketResponse(
            model: "\(data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24))"
        )
    }
}
