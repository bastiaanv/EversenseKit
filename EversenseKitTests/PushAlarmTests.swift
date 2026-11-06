@testable import EversenseKit
import Foundation
import LoopKit
import Testing

struct PushAlarmTests {
    private let date = Date(timeIntervalSinceReferenceDate: 800_000_000)

    private func alarm(_ code: Alarm) -> ActiveAlarm {
        ActiveAlarm(code: code, datetime: date, glucoseInMgDl: 0, flag: 0, priority: 0)
    }

    @Test func pushedAlarmIsNewAndKeepsOtherActiveAlarms() {
        let current = [alarm(.OneCal)]
        let afterPush = EversenseCGMManager.alarms(afterPush: alarm(.LowGlucoseAlarm), current: current)

        #expect(afterPush.map(\.code) == [.OneCal, .LowGlucoseAlarm])
        #expect(EversenseCGMManager.findNewAlarms(current: current, updated: afterPush).map(\.code) == [.LowGlucoseAlarm])
    }

    @Test func syncAfterPushRaisesNothingNew() {
        let afterPush = EversenseCGMManager.alarms(afterPush: alarm(.LowGlucoseAlarm), current: [alarm(.OneCal)])
        let synced = [alarm(.LowGlucoseAlarm), alarm(.OneCal)]

        #expect(EversenseCGMManager.findNewAlarms(current: afterPush, updated: synced).isEmpty)
    }

    @Test func repeatedPushReplacesTheSameAlarm() {
        let afterPush = EversenseCGMManager.alarms(afterPush: alarm(.LowGlucoseAlarm), current: [alarm(.LowGlucoseAlarm)])

        #expect(afterPush.map(\.code) == [.LowGlucoseAlarm])
    }
}

struct AlarmInterruptionLevelTests {
    @Test func infoAlarmsAreNormalPriority() {
        #expect(Alarm.OneCal.alarm.interruptionLevel == .active)
        #expect(Alarm.SensorRetiringSoon1Alarm.alarm.interruptionLevel == .active)
    }

    @Test func otherAlarmsStayTimeSensitive() {
        #expect(Alarm.LowGlucoseAlarm.alarm.interruptionLevel == .timeSensitive)
        #expect(Alarm.CalibrationNowAlarm.alarm.interruptionLevel == .timeSensitive)
    }
}
