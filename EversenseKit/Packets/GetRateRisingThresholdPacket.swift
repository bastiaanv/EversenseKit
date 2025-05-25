//
//  GetRateFallingThresholdResponse.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//


struct GetRateFallingThresholdResponse {
    let value: Double
}

class GetRateFallingThresholdPacket : BasePacket {
    typealias T = GetRateFallingThresholdResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.rateFallingThreshold)
    }
    
    func parseResponse(data: Data) -> GetRateFallingThresholdResponse {
        return GetRateFallingThresholdResponse(
            value: Double(data[start]) / 10
        )
    }
}