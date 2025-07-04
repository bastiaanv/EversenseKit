class SaveBleBondingInformationResponse {}

class SaveBleBondingInformationPacket: BasePacket {
    typealias T = SaveBleBondingInformationResponse

    var response: PacketIds {
        PacketIds.saveBLEBondingInformationResponseId
    }

    func getRequestData() -> Data {
        // 697f1c
        var data = Data([PacketIds.saveBLEBondingInformationCommandId.rawValue])
        let checksum = BinaryOperations.dataFrom16Bits(value: BinaryOperations.generateChecksumCRC16(data: data))
        data.append(checksum)

        return data
    }

    func parseResponse(data _: Data) -> SaveBleBondingInformationResponse {
        SaveBleBondingInformationResponse()
    }
}
