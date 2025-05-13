//
//  GetHysteresisPercentagePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetHysteresisPercentagePacketResponse {
    let value: UInt8
}

class GetHysteresisPercentagePacket : BasePacket {
    typealias T = GetHysteresisPercentagePacketResponse
    
    static var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.hysteresisPercentageAddress)
    }
    
    static func parseResponse(data: Data) -> GetHysteresisPercentagePacketResponse {
        return GetHysteresisPercentagePacketResponse(value: data[0])
    }
}
