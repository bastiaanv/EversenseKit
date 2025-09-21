extension EversenseE3 {
    class SaveBleBondingInformationResponse {}

    class SaveBleBondingInformationPacket: BasePacket {
        typealias T = SaveBleBondingInformationResponse

        var responseType: UInt8 {
            PacketIds.saveBLEBondingInformationResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            var data = Data([PacketIds.saveBLEBondingInformationCommandId.rawValue])

            let checksum = BinaryOperations.dataFrom16Bits(value: BinaryOperations.generateChecksumCRC16(data: data))
            data.append(checksum)

            return data
        }

        func parseResponse(data _: Data) -> SaveBleBondingInformationResponse {
            SaveBleBondingInformationResponse()
        }
    }
}
