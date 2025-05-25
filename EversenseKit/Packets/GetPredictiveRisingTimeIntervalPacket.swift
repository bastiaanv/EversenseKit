//
//  GetPredictiveFallingTimeIntervalResponse.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//


struct GetPredictiveRisingTimeIntervalResponse {
    let value: TimeInterval
}

class GetPredictiveRisingTimeIntervalPacket : BasePacket {
    typealias T = GetPredictiveRisingTimeIntervalResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.predictiveRisingTime)
    }
    
    func parseResponse(data: Data) -> GetPredictiveRisingTimeIntervalResponse {
        return GetPredictiveRisingTimeIntervalResponse(
            value: .minutes(Double(data[start]))
        )
    }
}
