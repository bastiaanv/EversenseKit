class GetCurrentDateTimeResponse {
    public let datetime: Date

    public init(datetime: Date) {
        self.datetime = datetime
    }
}

class GetCurrentDateTimePacket: BasePacket {
    typealias T = GetCurrentDateTimeResponse

    var response: PacketIds {
        PacketIds.readCurrentTransmitterDateAndTimeResponseId
    }

    func getRequestData() -> Data {
        var data = Data([PacketIds.readCurrentTransmitterDateAndTimeCommandId.rawValue])

        let checksum = BinaryOperations.dataFrom16Bits(value: BinaryOperations.generateChecksumCRC16(data: data))
        data.append(checksum)

        return data
    }

    func parseResponse(data: Data) -> GetCurrentDateTimeResponse {
        let date = BinaryOperations.toDateComponents(data: data, start: start)
        let time = BinaryOperations.toTimeComponents(data: data, start: start + 2)
        let timezoneOffset = BinaryOperations.toTimeComponents(data: data, start: start + 4)

        var offset = TimeInterval.hours(Double(timezoneOffset.hour ?? 0)) + TimeInterval
            .minutes(Double(timezoneOffset.minute ?? 0))
        let isTimezonePositive = data[start + 6] >= 0
        if !isTimezonePositive {
            offset *= -1
        }

        let timezone = TimeZone(secondsFromGMT: Int(offset))
        return GetCurrentDateTimeResponse(
            datetime: Date.fromComponents(
                date: date,
                time: time,
                timezone: timezone
            )
        )
    }
}
