//
//  GetRateAlertPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//

struct GetRateAlertResponse {
    let value: Bool
}

class GetRateAlertPacket : BasePacket {
    typealias T = GetRateAlertResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.rateAlert)
    }
    
    func parseResponse(data: Data) -> GetRateAlertResponse {
        return GetRateAlertResponse(
            value: data[start] == 0x55
        )
    }
}
