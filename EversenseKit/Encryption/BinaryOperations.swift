//
//  BinaryOperations.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

class BinaryOperations {
    static func dataFrom16Bits(value: UInt16) -> Data {
        return value > 255 ? Data([UInt8(value), UInt8(value >> 8)]) : Data([UInt8(value), 0])
    }
    
    static func dataFrom24Bits(value: UInt32) -> Data {
        return Data([UInt8(value), UInt8(value >> 8), UInt8(value >> 16)])
    }
    
    static func dataFrom32Bits(value: UInt32) -> Data {
        return Data([UInt8(value), UInt8(value >> 8), UInt8(value >> 16), UInt8(value >> 24)])
    }
    
    static func toDateComponents(data: Data) -> DateComponents {
        let day = data[0] & 31
        let year = (data[1] >> 1) + 2000
        var month = data[0] >> 5
        if (data[1] % 2 == 1) {
            month += 8
        }
        
        return DateComponents(year: Int(year), month: Int(month), day: Int(day))
    }
    
    static func toTimeComponents(data: Data) -> DateComponents {
        let hour = data[1] >> 3
        let minute = ((data[1] & 7) << 3) | (data[0] >> 5)
        let second = (data[0] & 31) * 2
        
        return DateComponents(hour: Int(hour), minute: Int(minute), second: Int(second))
    }
    
    static func generateChecksumCRC16(data: Data) -> UInt16 {
        var crc: UInt16 = 65535

        for byte in data {
            var currentByte = UInt16(byte)
            for _ in 0..<8 {
                let xor = (crc >> 15) ^ (currentByte >> 7)
                crc = (crc << 1) & 0xFFFF
                if xor > 0 {
                    crc = (crc ^ 4129) & 0xFFFF
                }
                currentByte = (currentByte << 1) & 0xFF
            }
        }

        return crc
    }
}
