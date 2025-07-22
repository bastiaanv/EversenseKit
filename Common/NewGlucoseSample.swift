import HealthKit
import LoopKit

extension NewGlucoseSample {
    init(cgmManager: EversenseCGMManager, value: UInt16, trend: GlucoseTrend, dateTime: Date) {
        self.init(
            date: dateTime,
            quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: Double(value)),
            condition: nil,
            trend: trend,
            trendRate: nil,
            isDisplayOnly: false,
            wasUserEntered: false,
            syncIdentifier: "\(dateTime.timeIntervalSince1970)\(value)",
            device: cgmManager.device
        )
    }
}
