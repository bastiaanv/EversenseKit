//
//  GetHysteresisPercentagePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetHysteresisPercentageResponse {
    let value: UInt8
}

class GetHysteresisPercentagePacket : BasePacket {
    typealias T = GetHysteresisPercentageResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.hysteresisPercentage)
    }
    
    func parseResponse(data: Data) -> GetHysteresisPercentageResponse {
        return GetHysteresisPercentageResponse(value: data[0])
    }
}
