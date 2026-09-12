enum EversenseE3 {
    enum PacketIds: UInt8 {
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
    }

    enum LogRangeType {
        case bloodGlucose
        case calibration

        func getRequestId() -> UInt8 {
            switch self {
            case .bloodGlucose:
                return PacketIds.readFirstAndLastSensorGlucoseRecordNumbersCommandId.rawValue
            case .calibration:
                return PacketIds.readFirstAndLastBloodGlucoseDataRecordNumbersCommandId.rawValue
            }
        }

        func getResponseId() -> UInt8 {
            switch self {
            case .bloodGlucose:
                return PacketIds.readFirstAndLastSensorGlucoseRecordNumbersResponseId.rawValue
            case .calibration:
                return PacketIds.readFirstAndLastBloodGlucoseDataRecordNumbersResponseId.rawValue
            }
        }
    }
}

enum Eversense365 {
    enum PacketIds: UInt8 {
        case OperationCommandId = 1
        case OperationResponseId = 65

        case AuthenticateV2CommandId = 9
        case AuthenticateV2ResponseId = 11

        case ReadCommandId = 2
        case ReadResponseId = 66
        case ReadLogsId = 98

        case WriteCommandId = 3
        case WriteResponseId = 67

        case NotificationId = 68

        case ErrorResponseId = 255
    }

    enum ReadIds: UInt8 {
        case Ping = 1
        case LogRangeOld = 9
        case SignalStrength = 27
        case CalibrationInfo = 29
        case GlucoseData = 31
        case SensorInformation = 32
        case PatientInformation = 33
        case ActiveAlerts = 34
        case LogRange = 56
        case LogValue = 58
    }

    enum OperationIds: UInt8 {
        case enterDiagnosticMode = 8
        case exitDiagnosticMode = 9
    }

    enum WriteIds: UInt8 {
        case CurrentDateTime = 1
        case Calibration = 12
        case AppVersion = 14
        case VibrateMode = 16
        case BleDisconnect = 17
        case PredictionLowThreshold = 18
        case PredictionHighThreshold = 19
        case RateFallingEnabled = 20
        case RateFallingThreshold = 21
        case RateRisingEnabled = 22
        case RateRisingThreshold = 23
        case PredictionLowEnabled = 24
        case PredictionLowTime = 25
        case PredictionHighEnabled = 26
        case PredictionHighTime = 27
        case HighGlucoseAlarmEnable = 28
        case HighGlucoseAlarm = 29
        case HighGlucoseAlarmRepeat = 30
        case LowGlucoseAlarm = 31
        case LowGlucoseAlarmRepeat = 32
    }

    enum AuthTypes: UInt8 {
        case AuthenticateV2WhoAmI = 1
        case AuthenticateV2Identity = 2
        case AuthenticateV2Start = 3
    }

    enum LogTypes: UInt8 {
        case Alerts = 0
        case Battery = 3
        case Calibrations = 6
        case Glucose = 13
    }

    enum PushIds: UInt8 {
        case KeepAlive = 2
        case AlarmWithData = 3
    }
}

protocol BasePacket<T> {
    associatedtype T = AnyClass

    var responseType: UInt8 { get }
    var responseId: UInt8? { get }

    func getRequestData() -> Data
    func parseResponse(data: Data) -> T
}

extension BasePacket {
    private var logger: EversenseLogger {
        EversenseLogger(category: "BasePacket")
    }

    var start: Int {
        if responseId != nil {
            return 2
        }

        switch responseType {
        case EversenseE3.PacketIds.readFourByteSerialFlashRegisterResponseId.rawValue,
             EversenseE3.PacketIds.readSingleByteSerialFlashRegisterResponseId.rawValue,
             EversenseE3.PacketIds.readTwoByteSerialFlashRegisterResponseId.rawValue:
            return 3

        default:
            return 0
        }
    }

    func checkPacket(data: Data, doChecksum: Bool) -> Bool {
        // Minlength of a packet is 2
        guard data.count >= 2 else {
            logger.error("Response is too short - data: \(data.hexString())")
            return false
        }

        // Check packetType
        guard data[0] == responseType else {
            logger.error("Invalid responseType, expected: \(responseType), got: \(data[0])")
            return false
        }

        if let responseId = responseId {
            guard data[1] == responseId else {
                logger.error("Invalid responseId, expected: \(responseId), got: \(data[1])")
                return false
            }
        }

        if !doChecksum {
            return true
        }

        let packet = Data(data.dropLast(2))
        let calculatedChecksum = BinaryOperations.dataFrom16Bits(value: BinaryOperations.generateChecksumCRC16(data: packet))
        let recievedChecksum = Data(data.subdata(in: data.count - 2 ..< data.count))

        if calculatedChecksum != recievedChecksum {
            logger.error("Checksum failed, expected: \(calculatedChecksum.hexString()), got: \(recievedChecksum.hexString())")
            return false
        }

        return true
    }
}
