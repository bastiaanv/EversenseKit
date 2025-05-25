//
//  GetHighGlucoseAlarmResponse.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//


struct GetLowGlucoseAlarmResponse {
    let valueInMgDl: UInt16
}

class GetLowGlucoseAlarmPacket : BasePacket {
    typealias T = GetLowGlucoseAlarmResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.lowGlucoseAlarmThreshold)
    }
    
    func parseResponse(data: Data) -> GetLowGlucoseAlarmResponse {
        return GetLowGlucoseAlarmResponse(
            valueInMgDl: UInt16(data[start]) | (UInt16(data[start+1]) << 8)
        )
    }
}
