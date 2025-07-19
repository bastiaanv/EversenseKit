import HealthKit
import LoopKit

extension NewGlucoseSample {
    init(cgmManager: EversenseCGMManager, value: UInt16, dateTime: Date) {
        self.init(
            date: dateTime,
            quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: Double(value)),
            condition: nil,
            trend: .flat, // TODO:
            trendRate: nil,
            isDisplayOnly: false,
            wasUserEntered: false,
            syncIdentifier: "\(dateTime.timeIntervalSince1970)\(value)",
            device: cgmManager.device
        )
    }
}
