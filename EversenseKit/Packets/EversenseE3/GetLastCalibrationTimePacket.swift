extension EversenseE3 {
    class GetLastCalibrationTimeResponse {
        let time: DateComponents

        init(time: DateComponents) {
            self.time = time
        }
    }

    class GetLastCalibrationTimePacket: BasePacket {
        typealias T = GetLastCalibrationTimeResponse

        var responseType: UInt8 {
            PacketIds.readTwoByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentCalibrationTime)
        }

        func parseResponse(data: Data) -> GetLastCalibrationTimeResponse {
            GetLastCalibrationTimeResponse(
                time: BinaryOperations.toTimeComponents(data: data, start: start)
            )
        }
    }
}
