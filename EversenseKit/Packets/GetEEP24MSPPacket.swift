//
//  GetEEP24MSPPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 18/05/2025.
//

struct GetEEP24MSPResponse {
    let value: Float
}

class GetEEP24MSPPacket : BasePacket {
    typealias T = GetEEP24MSPResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.eep24MSP)
    }
    
    func parseResponse(data: Data) -> GetEEP24MSPResponse {
        return GetEEP24MSPResponse(
            value: 1.0 - Float(data[start+1]) / 255.0
        )
    }
}
