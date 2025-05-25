//
//  GetRateFallingAlertPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//

struct GetRateFallingAlertResponse {
    let value: Bool
}

class GetRateFallingAlertPacket : BasePacket {
    typealias T = GetRateFallingAlertResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.rateFallingAlert)
    }
    
    func parseResponse(data: Data) -> GetRateFallingAlertResponse {
        return GetRateFallingAlertResponse(
            value: data[start] == 0x55
        )
    }
}
