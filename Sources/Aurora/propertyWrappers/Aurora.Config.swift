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

/// A type safe property wrapper to set and get values from UserDefaults with support for defaults values.
///
/// Usage:
/// ```
/// @AuroraConfig("isReady", default: false)
/// static var isReady: Bool
/// ```
///
/// [Apple documentation on UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults)
@propertyWrapper
public struct AuroraConfig<Value: AuroraConfigStoreValue> {
    /// A key in the current user‘s defaults database.
    let key: String

    /// A default value for the key in the current user‘s defaults database.
    let defaultValue: Value

    /// Current user's defaults database
    var userDefaults: UserDefaults

    /// Returns/set the object associated with the specified key.
    /// - Parameters:
    ///   - key: A key in the current user‘s defaults database.
    ///   - default: A default value for the key in the current user‘s defaults database.
    public init(_ key: String, `default`: Value) {
        self.key = "Aurora." + key
        self.defaultValue = `default`
        self.userDefaults = .standard
    }

    /// Wrapped userdefault
    public var wrappedValue: Value {
        get {
            return userDefaults.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            userDefaults.set(newValue, forKey: key)
        }
    }
}

/// A type than can be stored in `UserDefaults`.
///
/// From UserDefaults;
/// The value parameter can be only property list objects: NSData, NSString, NSNumber, NSDate, NSArray,
/// or NSDictionary.
/// For NSArray and NSDictionary objects, their contents must be property list objects. For more information,
/// see What is a Property List? in Property List Programming Guide.
public protocol AuroraConfigStoreValue {}

/// Make `Data` compliant to `AuroraConfigStoreValue`
extension Data: AuroraConfigStoreValue {}

/// Make `NSData` compliant to `AuroraConfigStoreValue`
extension NSData: AuroraConfigStoreValue {}

/// Make `String` compliant to `AuroraConfigStoreValue`
extension String: AuroraConfigStoreValue {}

/// Make `Date` compliant to `AuroraConfigStoreValue`
extension Date: AuroraConfigStoreValue {}

/// Make `NSDate` compliant to `AuroraConfigStoreValue`
extension NSDate: AuroraConfigStoreValue {}

/// Make `NSNumber` compliant to `AuroraConfigStoreValue`
extension NSNumber: AuroraConfigStoreValue {}

/// Make `Bool` compliant to `AuroraConfigStoreValue`
extension Bool: AuroraConfigStoreValue {}

/// Make `Int` compliant to `AuroraConfigStoreValue`
extension Int: AuroraConfigStoreValue {}

/// Make `Int8` compliant to `AuroraConfigStoreValue`
extension Int8: AuroraConfigStoreValue {}

/// Make `Int16` compliant to `AuroraConfigStoreValue`
extension Int16: AuroraConfigStoreValue {}

/// Make `Int32` compliant to `AuroraConfigStoreValue`
extension Int32: AuroraConfigStoreValue {}

/// Make `Int64` compliant to `AuroraConfigStoreValue`
extension Int64: AuroraConfigStoreValue {}

/// Make `UInt` compliant to `AuroraConfigStoreValue`
extension UInt: AuroraConfigStoreValue {}

/// Make `UInt8` compliant to `AuroraConfigStoreValue`
extension UInt8: AuroraConfigStoreValue {}

/// Make `UInt16` compliant to `AuroraConfigStoreValue`
extension UInt16: AuroraConfigStoreValue {}

/// Make `UInt32` compliant to `AuroraConfigStoreValue`
extension UInt32: AuroraConfigStoreValue {}

/// Make `UInt64` compliant to `AuroraConfigStoreValue`
extension UInt64: AuroraConfigStoreValue {}

/// Make `Double` compliant to `AuroraConfigStoreValue`
extension Double: AuroraConfigStoreValue {}

/// Make `Floar` compliant to `AuroraConfigStoreValue`
extension Float: AuroraConfigStoreValue {}

/// Make `Array` compliant to `AuroraConfigStoreValue`
extension Array: AuroraConfigStoreValue where Element: AuroraConfigStoreValue {}

/// Make `Dictionary` compliant to `AuroraConfigStoreValue`
extension Dictionary: AuroraConfigStoreValue where Key == String, Value: AuroraConfigStoreValue {}
