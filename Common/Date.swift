let GMTTimezone = TimeZone(abbreviation: "GMT") ?? TimeZone.current
let currentTimezone = TimeZone.current

let UNIX_2000 = TimeInterval.milliseconds(946_684_800_000)

extension Date {
    func toGmt() -> Date {
        let delta = TimeInterval(GMTTimezone.secondsFromGMT(for: self) - currentTimezone.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }

    func toLocal() -> Date {
        let delta = TimeInterval(currentTimezone.secondsFromGMT(for: self) - GMTTimezone.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }

    func toUnix2000() -> Data {
        let result = Int64(timeIntervalSince1970 - UNIX_2000) * 1024
        return result.toData(length: 8)
    }

    static func nowWithTimezone() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        var full = DateComponents()
        full.timeZone = TimeZone.current
        full.year = components.year
        full.month = components.month
        full.day = components.day
        full.hour = components.hour
        full.minute = components.minute
        full.second = components.second

        return Calendar.current.date(from: full)!
    }

    static func fromComponents(date: DateComponents, time: DateComponents, timezone: TimeZone? = nil) -> Date {
        var full = DateComponents()
        full.timeZone = timezone
        full.year = date.year
        full.month = date.month
        full.day = date.day
        full.hour = time.hour
        full.minute = time.minute
        full.second = time.second

        return Calendar.current.date(from: full)!.toLocal()
    }

    static func fromUnix2000(data: Data) -> Date {
        Date(timeIntervalSince1970: UNIX_2000 + .milliseconds(Double(data.toInt64() * 1024)))
    }

    static var defaultDayStartTime: Date {
        let components = DateComponents(timeZone: TimeZone.current, hour: 8, minute: 0)
        return Calendar.current.date(from: components)!
    }

    static var defaultNightStartTime: Date {
        let components = DateComponents(timeZone: TimeZone.current, hour: 20, minute: 0)
        return Calendar.current.date(from: components)!
    }
}
