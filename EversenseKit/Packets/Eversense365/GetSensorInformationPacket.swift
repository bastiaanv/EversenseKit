extension Eversense365 {
    class GetSensorInformationResponse {}

    class GetSensorInformationPacket: BasePacket {
        typealias T = GetSensorInformationResponse

        var response: PacketIds {
            // TEMP
            PacketIds.linkTransmitterWithSensorCommandId
        }

        func getRequestData() -> Data {
            let data = Data([0x02, 0x20])

            return CryptoUtil.shared.encrypt(data: data)
        }

        func parseResponse(data _: Data) -> Eversense365.GetSensorInformationResponse {
            GetSensorInformationResponse()
        }
    }
}
