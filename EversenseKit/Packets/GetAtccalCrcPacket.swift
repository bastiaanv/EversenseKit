class GetAtccalCrcResponse {
    let crc: UInt16
    let calcCrc: UInt16
    let isValid: Bool

    init(crc: UInt16, calcCrc: UInt16, isValid: Bool) {
        self.crc = crc
        self.calcCrc = calcCrc
        self.isValid = isValid
    }
}

class GetAtccalCrcPacket: BasePacket {
    typealias T = GetAtccalCrcResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.atccalCrcAddress)
    }

    func parseResponse(data: Data) -> GetAtccalCrcResponse {
        let crc = UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        let calcCrc = getCRCValue(getRequestData())

        return GetAtccalCrcResponse(
            crc: crc,
            calcCrc: calcCrc,
            isValid: crc == calcCrc
        )
    }

    private func getCRCValue(_ arr: Data) -> UInt16 {
        var crc: UInt32 = 0xFFFF

        for i2 in arr {
            crc ^= UInt32(i2) << 8

            for _ in 0 ..< 8 {
                if (crc & 32768) != 0 {
                    crc = (crc << 1) ^ 69665
                } else {
                    crc = crc << 1
                }
            }
        }

        return UInt16(crc ^ 0)
    }
}
