class GetVibrateModeResponse {
    let value: Bool?

    init(value: Bool?) {
        self.value = value
    }
}

class GetVibrateModePacket: BasePacket {
    typealias T = GetVibrateModeResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.vibrateMode)
    }

    func parseResponse(data: Data) -> GetVibrateModeResponse {
        GetVibrateModeResponse(
            value: data[start] == 0 ? false : data[start] == 0x55 ? true : nil
        )
    }
}
