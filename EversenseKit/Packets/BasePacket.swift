enum EversenseE3 {}
enum Eversense365 {}

protocol BasePacket<T> {
    associatedtype T = AnyClass

    var response: PacketIds { get }

    func getRequestData() -> Data
    func parseResponse(data: Data) -> T
}

extension BasePacket {
    var start: Int {
        response.getDataStart()
    }

    func checkPacket(data: Data, doChecksum: Bool) -> Bool {
        // Check packetId
        guard data[0] == response.rawValue else {
            return false
        }

        // Minlength of a packet is 2
        guard data.count >= 2 else {
            return false
        }

        if !doChecksum {
            return true
        }

        let packet = Data(data.dropLast(2))
        let calculatedChecksum = BinaryOperations.dataFrom16Bits(value: BinaryOperations.generateChecksumCRC16(data: packet))

        return calculatedChecksum == Data(data.subdata(in: data.count - 2 ..< data.count))
    }
}

enum PacketIds: UInt8 {
    case authenticateCommandId = 6
    case authenticateResponseId = 70
    case authenticateV2CommandId = 9
    case authenticateV2ResponseId = 11
    case assertSnoozeAgainsAlarmCommandId = 20
    case assertSnoozeAgainsAlarmResponseId = 148
    case calibrationAlertPush = 77
    case calibrationPush = 67
    case calibrationSwitchPush = 76
    case changeTimingParametersCommandId = 117
    case changeTimingParametersResponseId = 245
    case clearErrorFlagsCommandId = 4
    case clearErrorFlagsResponseId = 132
    case disconnectBLESavingBondingInformationCommandId = 116
    case disconnectBLESavingBondingInformationResponseId = 244
    case enterDiagnosticModeCommandId = 118
    case enterDiagnosticModeResponseId = 246
    case errorResponseId = 128
    case exerciseVibrationCommandId = 106
    case exerciseVibrationResponseId = 234
    case exitDiagnosticModeCommandId = 119
    case exitDiagnosticModeResponseId = 247
    case glucoseLevelAlarmPush = 64
    case glucoseLevelAlertPush = 65
    case hardwareStatusPush = 69
    case keepAlivePush = 80
    case linkTransmitterWithSensorCommandId = 2
    case linkTransmitterWithSensorResponseId = 130
    case markPatientEventRecordAsDeletedCommandId = 29
    case markPatientEventRecordAsDeletedResponseId = 157
    case pingCommandId = 1
    case pingResponseId = 129
    case rateAndPredictiveAlertPush = 66
    case readAllAvailableSensorsResponseId = 134
    case readAllSensorGlucoseAlertsInSpecifiedRangeCommandId = 113
    case readAllSensorGlucoseAlertsInSpecifiedRangeResponseId = 241
    case readAllSensorGlucoseDataInSpecifiedRangeCommandId = 112
    case readAllSensorGlucoseDataInSpecifiedRangeResponseId = 240
    case readCurrentTransmitterDateAndTimeCommandId = 25
    case readCurrentTransmitterDateAndTimeResponseId = 153
    case readFirstAndLastBloodGlucoseDataRecordNumbersCommandId = 23
    case readFirstAndLastBloodGlucoseDataRecordNumbersResponseId = 151
    case readFirstAndLastErrorLogRecordNumbersCommandId = 39
    case readFirstAndLastErrorLogRecordNumbersResponseId = 167
    case readFirstAndLastMiscEventLogRecordNumbersCommandId = 35
    case readFirstAndLastMiscEventLogRecordNumbersResponseId = 163
    case readFirstAndLastPatientEventRecordNumbersCommandId = 28
    case readFirstAndLastPatientEventRecordNumbersResponseId = 156
    case readFirstAndLastSensorGlucoseAlertRecordNumbersCommandId = 18
    case readFirstAndLastSensorGlucoseAlertRecordNumbersResponseId = 146
    case readFirstAndLastSensorGlucoseRecordNumbersCommandId = 14
    case readFirstAndLastSensorGlucoseRecordNumbersResponseId = 142
    case readFourByteSerialFlashRegisterCommandId = 46
    case readFourByteSerialFlashRegisterResponseId = 174
    case readLogOfBloodGlucoseDataInSpecifiedRangeCommandId = 114
    case readLogOfBloodGlucoseDataInSpecifiedRangeResponseId = 242
    case readLogOfPatientEventsInSpecifiedRangeCommandId = 115
    case readLogOfPatientEventsInSpecifiedRangeResponseId = 243
    case readNByteSerialFlashRegisterCommandId = 48
    case readNByteSerialFlashRegisterResponseId = 176
    case readSensorGlucoseAlertsAndStatusCommandId = 16
    case readSensorGlucoseAlertsAndStatusResponseId = 144
    case readSensorGlucoseCommandId = 8
    case readSensorGlucoseResponseId = 136
    case readSingleBloodGlucoseDataRecordCommandId = 22
    case readSingleBloodGlucoseDataRecordResponseId = 150
    case readSingleByteSerialFlashRegisterCommandId = 42
    case readSingleByteSerialFlashRegisterResponseId = 170
    case readSingleMiscEventLogCommandId = 34
    case readSingleMiscEventLogResponseId = 162
    case readSinglePatientEventCommandId = 27
    case readSinglePatientEventResponseId = 155
    case readSingleSensorGlucoseAlertRecordCommandId = 17
    case readSingleSensorGlucoseAlertRecordResponseId = 145
//    case readSingleSensorGlucoseDataRecordCommandId = 9
    case readSingleSensorGlucoseDataRecordResponseId = 137
    case readTwoByteSerialFlashRegisterCommandId = 44
    case readTwoByteSerialFlashRegisterResponseId = 172
    case resetTransmitterCommandId = 3
    case resetTransmitterResponseId = 131
    case saveBLEBondingInformationCommandId = 105
    case saveBLEBondingInformationResponseId = 233
    case sendBloodGlucoseDataCommandId = 21
    case sendBloodGlucoseDataResponseId = 149
    case sendBloodGlucoseDataWithTwoTimestampsCommandId = 60
    case sendBloodGlucoseDataWithTwoTimestampsResponseId = 188
    case sensorReadAlertPush = 73
    case sensorReplacement2Push = 75
    case sensorReplacementPush = 68
    case setCurrentTransmitterDateAndTimeCommandId = 7
    case setCurrentTransmitterDateAndTimeResponseId = 135
    case startSelfTestSequenceCommandId = 5
    case startSelfTestSequenceResponseId = 133
    // DISABLED SINCE IT HAS OVERLAP WITH OTHER COMMANDS
//    case testCommandChangeBatteryMonThresh = 42
//    case testCommandForceGlucoseMeasurement = 24
//    case testCommandId = 96
//    case testCommandReadNRawRegister = 7
    case testResponseId = 224
    case transmitterBatteryPush = 71
    case transmitterEOLPush = 74
    case writeFourByteSerialFlashRegisterCommandId = 47
    case writeFourByteSerialFlashRegisterResponseId = 175
    case writeNByteSerialFlashRegisterCommandId = 49
    case writeNByteSerialFlashRegisterResponseId = 177
    case writePatientEventCommandId = 26
    case writePatientEventResponseId = 154
    case writeSingleByteSerialFlashRegisterCommandId = 43
    case writeSingleByteSerialFlashRegisterResponseId = 171
    case writeSingleMiscEventLogRecordCommandId = 36
    case writeSingleMiscEventLogRecordResponseId = 164
    case writeTwoByteSerialFlashRegisterCommandId = 45
    case writeTwoByteSerialFlashRegisterResponseId = 173

    func getDataStart() -> Int {
        switch self {
        case .readFourByteSerialFlashRegisterResponseId,
             .readSingleByteSerialFlashRegisterResponseId,
             .readTwoByteSerialFlashRegisterResponseId:
            return 3

        default:
            return 0
        }
    }
}
