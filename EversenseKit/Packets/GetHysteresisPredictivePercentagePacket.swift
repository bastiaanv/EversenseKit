//
//  GetHysteresisPredictivePercentagePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetHysteresisPredictivePercentagePacketResponse {
    let value: UInt8
}

class GetHysteresisPredictivePercentagePacket : BasePacket {
    typealias T = GetHysteresisPredictivePercentagePacketResponse
    
    static var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.hysteresisPredictivePercentageAddress)
    }
    
    static func parseResponse(data: Data) -> GetHysteresisPredictivePercentagePacketResponse {
        return GetHysteresisPredictivePercentagePacketResponse(value: data[0])
    }
}
