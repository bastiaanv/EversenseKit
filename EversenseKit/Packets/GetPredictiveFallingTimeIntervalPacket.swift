//
//  GetPredictiveFallingTimeIntervalPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//

struct GetPredictiveFallingTimeIntervalResponse {
    let value: TimeInterval
}

class GetPredictiveFallingTimeIntervalPacket : BasePacket {
    typealias T = GetPredictiveFallingTimeIntervalResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.predictiveFallingTime)
    }
    
    func parseResponse(data: Data) -> GetPredictiveFallingTimeIntervalResponse {
        return GetPredictiveFallingTimeIntervalResponse(
            value: .minutes(Double(data[start]))
        )
    }
}
