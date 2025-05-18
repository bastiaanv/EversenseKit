//
//  GetHysteresisValuePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetHysteresisValueResponse {
    let valueInMgDl: UInt8
}

class GetHysteresisValuePacket : BasePacket {
    typealias T = GetHysteresisValueResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.hysteresisValue)
    }
    
    func parseResponse(data: Data) -> GetHysteresisValueResponse {
        return GetHysteresisValueResponse(valueInMgDl: data[0])
    }
}
