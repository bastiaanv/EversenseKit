//
//  GetMEPSavedDriftMetricPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 18/05/2025.
//

struct GetMEPSavedDriftMetricResponse {
    let value: Float
}

class GetMEPSavedDriftMetricPacket : BasePacket {
    typealias T = GetMEPSavedDriftMetricResponse
    
    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.mepSavedDriftMetric)
    }
    
    func parseResponse(data: Data) -> GetMEPSavedDriftMetricResponse {
        let bits = UInt32(data[start]) | (UInt32(data[start+1]) << 8) | (UInt32(data[start+2]) << 16) | (UInt32(data[start+3]) << 24)
        return GetMEPSavedDriftMetricResponse(value: Float(bitPattern: bits))
    }
}
