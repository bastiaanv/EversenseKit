//
//  GetAtccalCrcPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//

struct GetAtccalCrcResponse {
    let crc: UInt16
    let calcCrc: UInt16
    let isValid: Bool
}

class GetAtccalCrcPacket : BasePacket {
    typealias T = GetAtccalCrcResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.atccalCrcAddress)
    }
    
    func parseResponse(data: Data) -> GetAtccalCrcResponse {
        let crc = UInt16(data[start]) | (UInt16(data[start+1])<<8)
        let calcCrc = getCRCValue(getRequestData())
        
        return GetAtccalCrcResponse(
            crc: crc,
            calcCrc: calcCrc,
            isValid: crc == calcCrc
        )
    }
    
    private func getCRCValue(_ arr: Data) -> UInt16 {
        var crc: UInt16 = 0xFFFF
        
        for i2 in arr {
            crc ^= UInt16(i2) << 8
            
            for _ in 0..<8 {
                if (crc & 32768) != 0 {
                    crc = (crc << 1) ^ 69665
                } else {
                    crc = crc << 1
                }
            }
        }
        
        return crc ^ 0
    }
}
