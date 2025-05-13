//
//  GetVersionPacket 2.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetVersionExtendedPacketResponse {
    let extVersion: String
}

class GetVersionExtendedPacket : BasePacket {
    typealias T = GetVersionExtendedPacketResponse
    
    static var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.transmitterSoftwareVersionExtAddress)
    }
    
    static func parseResponse(data: Data) -> GetVersionExtendedPacketResponse {
        let extVersion = data[0..<4].compactMap { String(UnicodeScalar($0)) }.joined()
        return GetVersionExtendedPacketResponse(extVersion: extVersion)
    }
}
