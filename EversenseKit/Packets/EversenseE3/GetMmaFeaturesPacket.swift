extension EversenseE3 {
    class GetMmaFeaturesResponse {
        let value: UInt8

        init(value: UInt8) {
            self.value = value
        }
    }

    class GetMmaFeaturesPacket: BasePacket {
        typealias T = GetMmaFeaturesResponse

        var responseType: UInt8 {
            PacketIds.readSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.mmaFeatures)
        }

        func parseResponse(data: Data) -> GetMmaFeaturesResponse {
            GetMmaFeaturesResponse(
                value: data[start]
            )
        }
    }
}
