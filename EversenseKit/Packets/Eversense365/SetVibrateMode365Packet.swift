extension Eversense365 {
    class SetDoNotDisturbResponse {}

    class SetDoNotDisturbRequest: BasePacket {
        typealias T = SetDoNotDisturbResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.VibrateMode.rawValue
        }

        let silenced: Bool
        init(vibrationEnabled: Bool) {
            silenced = !vibrationEnabled
        }

        func getRequestData() -> Data {
            Data([PacketIds.WriteCommandId.rawValue, WriteIds.VibrateMode.rawValue, silenced ? 1 : 0])
        }

        func parseResponse(data _: Data) -> SetDoNotDisturbResponse {
            SetDoNotDisturbResponse()
        }
    }
}
