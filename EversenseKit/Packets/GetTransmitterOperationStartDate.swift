//
//  GetTransmitterOperationStartDate.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 18/05/2025.
//

struct GetTransmitterOperationStartDateResponse {
    let date: DateComponents
}

class GetTransmitterOperationStartDate : BasePacket {
    typealias T = GetTransmitterOperationStartDateResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.transmitterOperationStartDate)
    }
    
    func parseResponse(data: Data) -> GetTransmitterOperationStartDateResponse {
        return GetTransmitterOperationStartDateResponse(
            date: BinaryOperations.toDateComponents(data: data, start: start)
        )
    }
}
