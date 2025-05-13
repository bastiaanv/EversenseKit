//
//  GetRawValuePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 11/05/2025.
//

struct GetRawValuePacketResponse {
    let value: UInt16
}

class GetRawValuePacket : BasePacket {
    typealias T = GetRawValuePacketResponse
    
    private let memory: FlashMemory
    init(memory: FlashMemory) {
        self.memory = memory
    }
    
    static var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: self.memory)
    }
    
    static func parseResponse(data: Data) -> GetRawValuePacketResponse {
        return GetRawValuePacketResponse(value: UInt16(data[0]) | UInt16(data[1] << 8))
    }
}
