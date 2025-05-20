//
//  GetLowGlucoseAlarmRepeatIntervalDayTimePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 18/05/2025.
//

struct GetLowGlucoseAlarmRepeatIntervalDayTimeResponse {
    let value: UInt8
}

class GetLowGlucoseAlarmRepeatIntervalDayTimePacket : BasePacket {
    typealias T = GetLowGlucoseAlarmRepeatIntervalDayTimeResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.lowGlucoseAlarmRepeatIntervalDayTime)
    }
    
    func parseResponse(data: Data) -> GetLowGlucoseAlarmRepeatIntervalDayTimeResponse {
        return GetLowGlucoseAlarmRepeatIntervalDayTimeResponse(
            value: data[start]
        )
    }
}
