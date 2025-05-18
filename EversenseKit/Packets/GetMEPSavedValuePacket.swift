//
//  GetMEPSavedValuePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 18/05/2025.
//

struct GetMEPSavedValueResponse {
    let value: Float
}

class GetMEPSavedValuePacket : BasePacket {
    typealias T = GetMEPSavedValueResponse
    
    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.mepSavedValue)
    }
    
    func parseResponse(data: Data) -> GetMEPSavedValueResponse {
        let bits = UInt32(data[0]) | UInt32(data[1] << 8) | UInt32(data[2] << 16) | UInt32(data[3] << 24)
        return GetMEPSavedValueResponse(value: Float(bitPattern: bits))
    }
    
    
}
