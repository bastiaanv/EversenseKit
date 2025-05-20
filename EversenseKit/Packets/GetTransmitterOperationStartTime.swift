//
//  GetTransmitterOperationStartTime.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 18/05/2025.
//

struct GetTransmitterOperationStartTimeResponse {
    let time: DateComponents
}

class GetTransmitterOperationStartTime : BasePacket {
    typealias T = GetTransmitterOperationStartTimeResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.transmitterOperationStartTime)
    }
    
    func parseResponse(data: Data) -> GetTransmitterOperationStartTimeResponse {
        return GetTransmitterOperationStartTimeResponse(
            time: BinaryOperations.toTimeComponents(data: data, start: start)
        )
    }
}
