//
//  CommandError.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 13/05/2025.
//

enum CommandError: UInt16 {
    case notAllowed = 1
    case unused = 2
    case invalidCommandCode = 3
    case invalidCRC = 4
    case invalidMessageLength = 5
    case bufferOverflow = 6
    case invalidCommandArgument = 7
    case sensorReadError = 8
    case lowBatteryError = 9
    case sensorHardwareFailure = 10
    case transmitterHardwareFailure = 11
    case sensorUnableToBeLinked = 12
    case transmitterIsBusy = 13
    case invalidRecordNumberRange = 14
    case invalidRecord = 15
    case corruptRecord = 16
    case criticalFaultError = 17
    case crcErrorLogicalBlock = 18
    case accessDenied = 19
    case usbOnly = 20
    case noDataAvailable = 21
    case glucoseBlinded = 22
}
