//
//  GetHysteresisPredictivePercentagePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetHysteresisPredictivePercentageResponse {
    let value: UInt8
}

class GetHysteresisPredictivePercentagePacket : BasePacket {
    typealias T = GetHysteresisPredictivePercentageResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.hysteresisPredictivePercentage)
    }
    
    func parseResponse(data: Data) -> GetHysteresisPredictivePercentageResponse {
        return GetHysteresisPredictivePercentageResponse(value: data[0])
    }
}
