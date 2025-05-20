//
//  GetSensorInsertionDatePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 20/05/2025.
//

struct GetSensorInsertionDateResponse {
    let date: DateComponents
}

class GetSensorInsertionDatePacket : BasePacket {
    typealias T = GetSensorInsertionDateResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.sensorInsertionDate)
    }
    
    func parseResponse(data: Data) -> GetSensorInsertionDateResponse {
        return GetSensorInsertionDateResponse(
            date: BinaryOperations.toDateComponents(data: data, start: start)
        )
    }
}
