//
//  GetHysteresisPredictiveValuePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetHysteresisPredictiveValuePacketResponse {
    let valueInMgDl: UInt8
}

class GetHysteresisPredictiveValuePacket : BasePacket {
    typealias T = GetHysteresisPredictiveValuePacketResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.hysteresisPredictiveValueAddress)
    }
    
    func parseResponse(data: Data) -> GetHysteresisPredictiveValuePacketResponse {
        return GetHysteresisPredictiveValuePacketResponse(valueInMgDl: data[0])
    }
}
