class GetClinicalModeResponse {
    let value: Bool

    init(value: Bool) {
        self.value = value
    }
}

class GetClinicalModePacket: BasePacket {
    typealias T = GetClinicalModeResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.clinicalMode)
    }

    func parseResponse(data: Data) -> GetClinicalModeResponse {
        GetClinicalModeResponse(
            value: data[start] == 0x55
        )
    }
}
