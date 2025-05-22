//
//  GetCalibrationMinThresholdPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 22/05/2025.
//

struct GetCalibrationMinThresholdResponse {
    let value: UInt16
}

class GetCalibrationMinThresholdPacket : BasePacket {
    typealias T = GetCalibrationMinThresholdResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.minCalibrationThreshold)
    }
    
    func parseResponse(data: Data) -> GetCalibrationMinThresholdResponse {
        return GetCalibrationMinThresholdResponse(
            value: UInt16(data[start]) | (UInt16(data[start+1]) << 8)
        )
    }
}
