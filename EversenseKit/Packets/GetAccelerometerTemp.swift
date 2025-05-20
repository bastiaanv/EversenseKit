//
//  GetAccelerometerTemp.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 11/05/2025.
//

struct GetAccelerometerTempResponse {
    let value: UInt16
}

class GetAccelerometerTemp : BasePacket {
    typealias T = GetAccelerometerTempResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.accelerometerTemp)
    }
    
    func parseResponse(data: Data) -> GetAccelerometerTempResponse {
        return GetAccelerometerTempResponse(
            value: UInt16(data[start]) | (UInt16(data[start+1]) << 8)
        )
    }
}
