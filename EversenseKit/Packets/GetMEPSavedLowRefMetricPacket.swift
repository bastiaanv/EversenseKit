//
//  GetMEPSavedLowRefMetricPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 18/05/2025.
//

struct GetMEPSavedLowRefMetricResponse {
    let value: Float
}

class GetMEPSavedLowRefMetricPacket: BasePacket {
    typealias T = GetMEPSavedLowRefMetricResponse
    
    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.mepSavedLowRefMetric)
    }
    
    func parseResponse(data: Data) -> GetMEPSavedLowRefMetricResponse {
        let bits = UInt32(data[0]) | UInt32(data[1] << 8) | UInt32(data[2] << 16) | UInt32(data[3] << 24)
        return GetMEPSavedLowRefMetricResponse(value: Float(bitPattern: bits))
    }
}
