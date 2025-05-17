//
//  GetAccelerometerValues.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 11/05/2025.
//

struct GetAccelerometerValuesResponse {
    let value: UInt16
}

class GetAccelerometerValues : BasePacket {
    typealias T = GetAccelerometerValuesResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.accelerometerValuesAddress)
    }
    
    func parseResponse(data: Data) -> GetAccelerometerValuesResponse {
        return GetAccelerometerValuesResponse(value: UInt16(data[0]) | UInt16(data[1] << 8))
    }
}
