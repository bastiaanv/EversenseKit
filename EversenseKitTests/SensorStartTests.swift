@testable import EversenseKit
import Foundation
import Testing

struct SensorStartTests {
    @Test func insertionFlagFromEarlierVersionsMeansTheCurrentSensor() {
        let state = EversenseCGMState(rawValue: ["sensorId": Data([0x0A, 0x0B]), "hasReportedInsertionDate": true])
        #expect(state.sensorStartReportedFor == Data([0x0A, 0x0B]).hexString())
    }

    @Test func noSensorStartReportedWithoutTheFlag() {
        let state = EversenseCGMState(rawValue: ["sensorId": Data([0x0A, 0x0B])])
        #expect(state.sensorStartReportedFor == nil)
    }
}
