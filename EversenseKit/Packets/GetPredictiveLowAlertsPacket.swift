//
//  GetPredictiveLowAlertsPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//

struct GetPredictiveLowAlertsResponse {
    let value: Bool
}

class GetPredictiveLowAlertsPacket : BasePacket {
    typealias T = GetPredictiveLowAlertsResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.predictiveLowAlert)
    }
    
    func parseResponse(data: Data) -> GetPredictiveLowAlertsResponse {
        return GetPredictiveLowAlertsResponse(
            value: data[start] == 0x55
        )
    }
}
