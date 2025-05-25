//
//  GetRateFallingThresholdResponse.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//


struct GetRateRisingThresholdResponse {
    let value: Double
}

class GetRateRisingThresholdPacket : BasePacket {
    typealias T = GetRateRisingThresholdResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.rateRisingThreshold)
    }
    
    func parseResponse(data: Data) -> GetRateRisingThresholdResponse {
        return GetRateRisingThresholdResponse(
            value: Double(data[start]) / 10
        )
    }
}
