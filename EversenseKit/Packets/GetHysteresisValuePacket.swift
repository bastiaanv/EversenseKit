//
//  GetHysteresisValuePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetHysteresisValuePacketResponse {
    let valueInMgDl: UInt8
}

class GetHysteresisValuePacket : BasePacket {
    typealias T = GetHysteresisValuePacketResponse
    
    static var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.hysteresisValueAddress)
    }
    
    static func parseResponse(data: Data) -> GetHysteresisValuePacketResponse {
        return GetHysteresisValuePacketResponse(valueInMgDl: data[0])
    }
}
