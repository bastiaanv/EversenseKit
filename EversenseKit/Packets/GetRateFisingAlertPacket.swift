//
//  GetRateFallingAlert.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//


struct GetRateRisingAlertResponse {
    let value: Bool
}

class GetRateRisingAlertPacket : BasePacket {
    typealias T = GetRateRisingAlertResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.rateRisingAlert)
    }
    
    func parseResponse(data: Data) -> GetRateRisingAlertResponse {
        return GetRateRisingAlertResponse(
            value: data[start] == 0x55
        )
    }
}
