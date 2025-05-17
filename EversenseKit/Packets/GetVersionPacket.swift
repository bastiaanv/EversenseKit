//
//  GetVersionPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetVersionPacketResponse {
    let version: String
}

class GetVersionPacket : BasePacket {
    typealias T = GetVersionPacketResponse
    
    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.transmitterSoftwareVersionAddress)
    }
    
    func parseResponse(data: Data) -> GetVersionPacketResponse {
        let version = data[0..<4].compactMap { String(UnicodeScalar($0)) }.joined()
        return GetVersionPacketResponse(version: version)
    }
}
