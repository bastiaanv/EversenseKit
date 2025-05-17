//
//  Date.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 17/05/2025.
//

let GMTTimezone = TimeZone(abbreviation: "GMT") ?? TimeZone.current
let currentTimezone = TimeZone.current


extension Date {
    func toGmt() -> Date {
        let delta = TimeInterval(GMTTimezone.secondsFromGMT(for: self) - currentTimezone.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }
    
    func toLocal() -> Date {
        let delta = TimeInterval(currentTimezone.secondsFromGMT(for: self) - GMTTimezone.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }
    
    static func fromComponents(date: DateComponents, time: DateComponents) -> Date {
        var full = DateComponents()
        full.timeZone = GMTTimezone
        full.year = date.year
        full.month = date.month
        full.day = date.day
        full.hour = time.hour
        full.minute = time.minute
        full.second = time.second
        
        return Calendar.current.date(from: full)!.toLocal()
    }
    
    static var defaultDayStartTime: Date {
        var components = DateComponents(timeZone: TimeZone.current, hour: 8, minute: 0)
        return Calendar.current.date(from: components)!
    }
    
    static var defaultNightStartTime: Date {
        var components = DateComponents(timeZone: TimeZone.current, hour: 20, minute: 0)
        return Calendar.current.date(from: components)!
    }
}
