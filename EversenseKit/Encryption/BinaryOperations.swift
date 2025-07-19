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

    static func toDateArray(date: Date) -> Data {
        let year = UInt8(Calendar.current.component(.year, from: date) - 2000)
        let month = UInt8(Calendar.current.component(.month, from: date))
        let day = UInt8(Calendar.current.component(.day, from: date))

        let byte1 = (month << 5) | day
        let byte2 = (year << 1) | (month >= 8 ? 1 : 0)
        return Data([byte1, byte2])
    }

    static func toTimeArray(date: Date) -> Data {
        let hour = UInt8(Calendar.current.component(.hour, from: date))
        let minute = UInt8(Calendar.current.component(.minute, from: date))
        let seconds = UInt8(Calendar.current.component(.second, from: date))

        let byte1 = ((minute & 7) << 5) | (seconds / 2)
        let byte2 = (hour << 3) | ((minute & 56) >> 3)
        return Data([byte1, byte2])
    }

    static func toTimeZoneArray() -> Data {
        let offset = TimeInterval(Double(TimeZone.current.secondsFromGMT()))
        let hour = UInt8(offset.hours)
        let minute = UInt8(offset.minutes) % 60

        let byte1 = ((minute & 7) << 5)
        let byte2 = (hour << 3) | ((minute & 56) >> 3)
        return Data([byte1, byte2])
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
