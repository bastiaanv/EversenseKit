extension EversenseE3 {
    class SetCurrentDateTimeResponse {}

    class SetCurrentDateTimePacket: BasePacket {
        typealias T = SetCurrentDateTimeResponse

        var response: PacketIds {
            PacketIds.setCurrentTransmitterDateAndTimeResponseId
        }

        func getRequestData() -> Data {
            var data = Data([PacketIds.setCurrentTransmitterDateAndTimeCommandId.rawValue])
            let now = Date().toGmt()

            data.append(BinaryOperations.toDateArray(date: now))
            data.append(BinaryOperations.toTimeArray(date: now))
            data.append(BinaryOperations.toTimeZoneArray())
            data.append(TimeZone.current.secondsFromGMT() >= 0 ? 0 : 255)

            let checksum = BinaryOperations.dataFrom16Bits(value: BinaryOperations.generateChecksumCRC16(data: data))
            data.append(checksum)

            return data
        }

        func parseResponse(data _: Data) -> SetCurrentDateTimeResponse {
            SetCurrentDateTimeResponse()
        }
    }
}
