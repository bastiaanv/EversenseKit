//
//  GetCalibrationMinThresholdResponse.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 22/05/2025.
//


struct GetCalibrationMaxThresholdResponse {
    let value: UInt16
}

class GetCalibrationMaxThresholdPacket : BasePacket {
    typealias T = GetCalibrationMaxThresholdResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.maxCalibrationThreshold)
    }
    
    func parseResponse(data: Data) -> GetCalibrationMaxThresholdResponse {
        return GetCalibrationMaxThresholdResponse(
            value: UInt16(data[start]) | (UInt16(data[start+1]) << 8)
        )
    }
}
