class GetRecentGlucoseTimeResponse {
    let time: DateComponents

    init(time: DateComponents) {
        self.time = time
    }
}

class GetRecentGlucoseTimePacket: BasePacket {
    typealias T = GetRecentGlucoseTimeResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentGlucoseTime)
    }

    func parseResponse(data: Data) -> GetRecentGlucoseTimeResponse {
        GetRecentGlucoseTimeResponse(
            time: BinaryOperations.toTimeComponents(data: data, start: start)
        )
    }
}
