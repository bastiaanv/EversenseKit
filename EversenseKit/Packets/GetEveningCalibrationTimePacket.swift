//
//  GetEveningCalibrationTimePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 22/05/2025.
//


struct GetEveningCalibrationTimeResponse {
    let value: DateComponents
}

class GetEveningCalibrationTimePacket : BasePacket {
    typealias T = GetEveningCalibrationTimeResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.eveningCalibrationTime)
    }
    
    func parseResponse(data: Data) -> GetEveningCalibrationTimeResponse {
        let components = DateComponents(
            timeZone: GMTTimezone,
            hour: Int(data[start]),
            minute: Int(data[start + 1]),
            second: 0
        )
        return GetEveningCalibrationTimeResponse(value: components)
    }
}
