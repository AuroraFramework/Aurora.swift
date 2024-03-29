// Aurora framework for Swift
//
// The **Aurora.framework** contains a base for your project.
//
// It has a lot of extensions built-in to make development easier.
//
// - Version: 1.0
// - Copyright: [Wesley de Groot](https://wesleydegroot.nl) ([WDGWV](https://wdgwv.com))\
//  and [Contributors](https://github.com/AuroraFramework/Aurora.swift/graphs/contributors).
//
// Thanks for using!
//
// Licence: MIT

import Foundation

public extension Date {
    /// The day of the date.
    var day: Int {
        get {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: self)

            return components.day ?? 0
        }
        set {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
            components.day = newValue
            guard let newDate = calendar.date(from: components) else { return }

            self = newDate
        }
    }

    /// The month of the date.
    var month: Int {
        get {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.month], from: self)

            return components.month ?? 0
        }
        set {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
            components.month = newValue
            guard let newDate = calendar.date(from: components) else { return }

            self = newDate
        }
    }

    /// The year of the date.
    var year: Int {
        get {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year], from: self)

            return components.year ?? 0
        }
        set {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
            components.year = newValue
            guard let newDate = calendar.date(from: components) else { return }

            self = newDate
        }
    }

    /// Returns a new Date by setting this Date's day to first.
    var firstOfMonth: Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)

        return calendar.date(from: components)
    }

    /// Returns a new Date by setting this Date's day to last.
    var lastOfMonth: Date? {
        guard let firstOfMonth = firstOfMonth else { return nil }

        var components = DateComponents()
        components.month = 1
        components.day = -1

        return Calendar.current.date(byAdding: components, to: firstOfMonth)
    }

    /// Returns a new Date by setting this Date's day and month to first.
    var firstOfYear: Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)

        return calendar.date(from: components)
    }

    /// Returns a new Date by setting this Date's day and month to last.
    var lastOfYear: Date? {
        guard let firstOfYear = firstOfYear else { return nil }

        var components = DateComponents()
        components.year = 1
        components.day = -1

        return Calendar.current.date(byAdding: components, to: firstOfYear)
    }

    /// Returns a new Date with the day following this Date.
    var nextDay: Date? {
        var components = DateComponents()
        components.day = 1

        return Calendar.current.date(byAdding: components, to: self)
    }

    /// Returns a new Date with the day preceding this Date.
    var previousDay: Date? {
        var components = DateComponents()
        components.day = -1

        return Calendar.current.date(byAdding: components, to: self)
    }

    /// Returns a weekday or count of weekdays.
    /// - note: This value is interpreted in the context of the current calendar.
    var weekday: Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: self)

        return components.weekday
    }

    /// Check if a `Date` is in the future.
    /// - Returns: Bool.
    var isInFuture: Bool {
        return self > Date()
    }

    /// Check if a `Date` is in the past.
    /// - Returns: Bool.
    var isInPast: Bool {
        return self < Date()
    }

    /// To string
    /// - Parameter format: With format
    /// - Returns: Date/Time as String
    func toString(format: String) -> String {
        let dformatter = DateFormatter()
        dformatter.dateFormat = format
        return dformatter.string(from: self)
    }

    /// Alias for `timeIntervalSince1970`
    var unixTime: Double {
        return self.timeIntervalSince1970
    }

    /// Returns the difference between the dates in seconds
    static func - (lhs: Date, rhs: Date) -> Double {
        return lhs.unixTime - rhs.unixTime
    }

    /// Adds the unix time for the dates together
    static func + (lhs: Date, rhs: Date) -> Double {
        return lhs.unixTime - rhs.unixTime
    }
}
