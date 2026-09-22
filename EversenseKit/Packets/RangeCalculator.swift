enum RangeCalculator {
    public static func calculateGlucoseRange(rangeFrom: UInt32, rangeTo: UInt32, lastGlucoseTimestamp: Date) -> RangeCalculation {
        let timeDiff = (Date.now.timeIntervalSince(lastGlucoseTimestamp) / TimeInterval.minutes(5)).rounded(.up)

        // Maximum page fetch = 20
        let pageCount = min(UInt32(max(timeDiff + 2, 0)), 20)
        var from = rangeTo >= pageCount ? rangeTo - pageCount : 0
        if from < rangeFrom {
            from = rangeFrom
        }

        return RangeCalculation(from: from, to: rangeTo)
    }

    public static func calculateRange(rangeFrom: UInt32, rangeTo: UInt32) -> RangeCalculation {
        let count = min(rangeTo - rangeFrom, 20)
        var from = rangeTo - count
        if from < rangeFrom {
            from = rangeFrom
        }

        return RangeCalculation(from: from, to: rangeTo)
    }

    public static func calculateRange(lastRecord: UInt32, rangeFrom: UInt32, rangeTo: UInt32) -> RangeCalculation? {
        if rangeTo == lastRecord {
            // Already up-to-date
            return nil
        }

        let count = min(rangeTo - rangeFrom, 20)
        var from = max(rangeTo - count, lastRecord)
        if from < rangeFrom {
            from = rangeFrom
        }

        return RangeCalculation(from: from, to: rangeTo)
    }
}

struct RangeCalculation {
    let from: UInt32
    let to: UInt32
}
