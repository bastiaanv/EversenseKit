//
//  GetPredictiveAlertsPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//

struct GetPredictiveAlertsResponse {
    let value: Bool
}

class GetPredictiveAlertsPacket : BasePacket {
    typealias T = GetPredictiveAlertsResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.predictiveAlert)
    }
    
    func parseResponse(data: Data) -> GetPredictiveAlertsResponse {
        return GetPredictiveAlertsResponse(
            value: data[start] == 0x55
        )
    }
}
