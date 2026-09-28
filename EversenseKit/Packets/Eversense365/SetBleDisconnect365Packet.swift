extension Eversense365 {
    class SetBleDisconnectResponse {}

    class SetBleDisconnectPacket: BasePacket {
        typealias T = SetBleDisconnectResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.BleDisconnect.rawValue
        }

        let interval: TimeInterval
        init(interval: TimeInterval) {
            self.interval = interval
        }

        func getRequestData() -> Data {
            var data = Data([PacketIds.WriteCommandId.rawValue, WriteIds.BleDisconnect.rawValue])
            data.append(BinaryOperations.dataFrom16Bits(value: UInt16(interval)))

            return data
        }

        func parseResponse(data _: Data) -> SetBleDisconnectResponse {
            SetBleDisconnectResponse()
        }
    }
}
