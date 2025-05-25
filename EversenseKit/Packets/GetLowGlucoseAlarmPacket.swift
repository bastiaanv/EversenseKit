//
//  GetHighGlucoseAlarmResponse.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//


struct GetHighGlucoseAlarmResponse {
    let valueInMgDl: UInt16
}

class GetHighGlucoseAlarmPacket : BasePacket {
    typealias T = GetHighGlucoseAlarmResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.highGlucoseAlarmThreshold)
    }
    
    func parseResponse(data: Data) -> GetHighGlucoseAlarmResponse {
        return GetHighGlucoseAlarmResponse(
            valueInMgDl: UInt16(data[start]) | (UInt16(data[start+1]) << 8)
        )
    }
}