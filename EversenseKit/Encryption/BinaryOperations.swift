enum BinaryOperations {
    static func dataFrom16Bits(value: UInt16) -> Data {
        value > 255 ? Data([UInt8(value & 255), UInt8((value >> 8) & 255)]) : Data([UInt8(value), 0])
    }

    static func dataFrom24Bits(value: UInt32) -> Data {
        Data([UInt8(value & 255), UInt8((value >> 8) & 255), UInt8((value >> 16) & 255)])
    }

    static func dataFrom32Bits(value: UInt32) -> Data {
        Data([UInt8(value & 255), UInt8((value >> 8) & 255), UInt8((value >> 16) & 255), UInt8((value >> 24) & 255)])
    }

    static func toDateComponents(data: Data, start: Int) -> DateComponents {
        let day = data[start] & 31
        let year = Int(data[start + 1] >> 1) + 2000
        var month = data[start] >> 5
        if data[start + 1] % 2 == 1 {
            month += 8
        }

        return DateComponents(year: year, month: Int(month), day: Int(day))
    }

    static func toTimeComponents(data: Data, start: Int) -> DateComponents {
        let hour = data[start + 1] >> 3
        let minute = ((data[start + 1] & 7) << 3) | (data[start] >> 5)
        let second = (data[start] & 31) * 2

        return DateComponents(hour: Int(hour), minute: Int(minute), second: Int(second))
    }

    static func generateChecksumCRC16(data: Data) -> UInt16 {
        var crc: UInt16 = 65535

        for byte in data {
            var currentByte = UInt16(byte)
            for _ in 0 ..< 8 {
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
