class GetClinicalModeDurationResponse {
    let value: TimeInterval

    init(value: TimeInterval) {
        self.value = value
    }
}

class GetClinicalModeDurationPacket: BasePacket {
    typealias T = GetClinicalModeDurationResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.clinicalModeDuration)
    }

    func parseResponse(data: Data) -> GetClinicalModeDurationResponse {
        let value = UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        return GetClinicalModeDurationResponse(
            value: .minutes(Double(value))
        )
    }
}
