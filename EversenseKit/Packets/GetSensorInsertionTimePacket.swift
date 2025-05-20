//
//  GetSensorInsertionDateResponse.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 20/05/2025.
//


struct GetSensorInsertionTimeResponse {
    let time: DateComponents
}

class GetSensorInsertionTimePacket : BasePacket {
    typealias T = GetSensorInsertionTimeResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.sensorInsertionTime)
    }
    
    func parseResponse(data: Data) -> GetSensorInsertionTimeResponse {
        return GetSensorInsertionTimeResponse(
            time: BinaryOperations.toTimeComponents(data: data, start: start)
        )
    }
}
