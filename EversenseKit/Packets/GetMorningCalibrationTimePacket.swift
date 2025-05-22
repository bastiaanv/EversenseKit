//
//  GetMorningCalibrationTimePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 22/05/2025.
//

struct GetMorningCalibrationTimeResponse {
    let value: DateComponents
}

class GetMorningCalibrationTimePacket : BasePacket {
    typealias T = GetMorningCalibrationTimeResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.morningCalibrationTime)
    }
    
    func parseResponse(data: Data) -> GetMorningCalibrationTimeResponse {
        let components = DateComponents(
            timeZone: GMTTimezone,
            hour: Int(data[start]),
            minute: Int(data[start + 1]),
            second: 0
        )
        return GetMorningCalibrationTimeResponse(value: components)
    }
}
