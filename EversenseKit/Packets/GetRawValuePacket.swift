//
//  GetRawValuePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 11/05/2025.
//

struct GetRawValueResponse {
    let value: UInt16
}

class GetRawValuePacket : BasePacket {
    typealias T = GetRawValueResponse
    
    private let memory: FlashMemory
    init(memory: FlashMemory) {
        self.memory = memory
    }
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: self.memory)
    }
    
    func parseResponse(data: Data) -> GetRawValueResponse {
        return GetRawValueResponse(value: UInt16(data[0]) | UInt16(data[1] << 8))
    }
}
