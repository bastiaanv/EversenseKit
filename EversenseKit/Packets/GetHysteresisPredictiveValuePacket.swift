//
//  GetHysteresisPredictiveValuePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetHysteresisPredictiveValueResponse {
    let valueInMgDl: UInt8
}

class GetHysteresisPredictiveValuePacket : BasePacket {
    typealias T = GetHysteresisPredictiveValueResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.hysteresisPredictiveValue)
    }
    
    func parseResponse(data: Data) -> GetHysteresisPredictiveValueResponse {
        return GetHysteresisPredictiveValueResponse(valueInMgDl: data[0])
    }
}
