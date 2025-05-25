//
//  GetRateFallingAlert.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//


struct GetRateRisingAlert {
    let value: Bool
}

class GetRateFisingAlertPacket : BasePacket {
    typealias T = GetRateRisingAlert
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.rateRisingAlert)
    }
    
    func parseResponse(data: Data) -> GetRateRisingAlert {
        return GetRateRisingAlert(
            value: data[start] == 0x55
        )
    }
}
