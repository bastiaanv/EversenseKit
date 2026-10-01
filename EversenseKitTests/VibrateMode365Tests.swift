@testable import EversenseKit
import Foundation
import Testing

struct VibrateMode365Tests {
    // The 365 stores Do Not Disturb, not vibration: writing 1 silences the transmitter (issue #15)
    static let doNotDisturbByVibration: [(vibrationEnabled: Bool, doNotDisturb: UInt8)] = [
        (true, 0x00),
        (false, 0x01)
    ]

    @Test(arguments: doNotDisturbByVibration) func writesDoNotDisturbAsInverseOfVibration(
        vibrationEnabled: Bool,
        doNotDisturb: UInt8
    ) {
        let request = Eversense365.SetDoNotDisturbRequest(vibrationEnabled: vibrationEnabled)

        #expect(request.getRequestData() == Data([
            Eversense365.PacketIds.WriteCommandId.rawValue,
            Eversense365.WriteIds.VibrateMode.rawValue,
            doNotDisturb
        ]))
    }

    @Test(arguments: doNotDisturbByVibration) func readsVibrationAsInverseOfDoNotDisturb(
        vibrationEnabled: Bool,
        doNotDisturb: UInt8
    ) {
        var data = Data(repeating: 0, count: Eversense365.GetPatientSettingsPacket.Offset.BATTERY_TEMP_THRESH_WARN + 1)
        data[Eversense365.GetPatientSettingsPacket.Offset.IS_DO_NOT_DISTURB_ENABLED] = doNotDisturb

        let settings = Eversense365.GetPatientSettingsPacket().parseResponse(data: data)

        #expect(settings.vibrateMode == vibrationEnabled)
    }
}
