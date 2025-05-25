//
//  GetPredictiveLowAlertsResponse.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//


struct GetPredictiveHighAlertsResponse {
    let value: Bool
}

class GetPredictiveHighAlertsPacket : BasePacket {
    typealias T = GetPredictiveHighAlertsResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.predictiveHighAlert)
    }
    
    func parseResponse(data: Data) -> GetPredictiveHighAlertsResponse {
        return GetPredictiveHighAlertsResponse(
            value: data[start] == 0x55
        )
    }
}
