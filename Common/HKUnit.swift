import HealthKit

extension HKUnit {
    static let milligramsPerDeciliter: HKUnit = {
        HKUnit.gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci))
    }()

    static let milligramsPerDeciliterPerMinute: HKUnit = {
        HKUnit.gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci)).unitDivided(by: .minute())
    }()
}
