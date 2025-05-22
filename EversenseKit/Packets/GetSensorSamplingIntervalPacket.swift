//
//  GetSensorSamplingIntervalPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 22/05/2025.
//

struct GetSensorSamplingIntervalResponse {
    let value: TimeInterval
}

class GetSensorSamplingIntervalPacket : BasePacket {
    typealias T = GetSensorSamplingIntervalResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.sensorGlucoseSamplingInterval)
    }
    
    func parseResponse(data: Data) -> GetSensorSamplingIntervalResponse {
        let value = UInt16(data[start]) | (UInt16(data[start+1]) << 8)
        return GetSensorSamplingIntervalResponse(
            value: .seconds(Double(value))
        )
    }
}
