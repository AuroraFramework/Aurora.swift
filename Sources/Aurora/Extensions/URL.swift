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
// Please note: this is a beta version.
// It can contain bugs, please report all bugs to https://github.com/AuroraFramework/Aurora.swift
//
// Thanks for using!
//
// Licence: Needs to be decided.

import Foundation

extension URL: ExpressibleByStringLiteral {
    /// <#Description#>
    /// - Parameter value: <#value description#>
    public init(stringLiteral value: String) {
        guard let url = URL(string: value) else {
            fatalError("\(value) is an invalid url")
        }
        self = url
    }
    
    /// <#Description#>
    /// - Parameter value: <#value description#>
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
    
    /// <#Description#>
    /// - Parameter value: <#value description#>
    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }
}
