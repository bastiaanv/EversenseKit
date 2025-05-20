//
//  GetHighGlucoseAlarmRepeatIntervalDayTimeResponse.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 18/05/2025.
//


struct GetLowGlucoseAlarmRepeatIntervalNightTimeResponse {
    let value: UInt8
}

class GetLowGlucoseAlarmRepeatIntervalNightTimePacket : BasePacket {
    typealias T = GetLowGlucoseAlarmRepeatIntervalNightTimeResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.lowGlucoseAlarmRepeatIntervalNightTime)
    }
    
    func parseResponse(data: Data) -> GetLowGlucoseAlarmRepeatIntervalNightTimeResponse {
        return GetLowGlucoseAlarmRepeatIntervalNightTimeResponse(
            value: data[start]
        )
    }
}
