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

/// Aurora error
struct AuroraError {
    /// The error message
    let message: String
}

extension AuroraError: LocalizedError {
    /// the Error description
    var errorDescription: String? {
        return NSLocalizedString(message, bundle: Bundle.module, comment: message)
    }

    /// Failure reaseon
    var failureReason: String? {
        return NSLocalizedString(message, bundle: Bundle.module, comment: message)
    }

    /// Recovery suggestion
    var recoverySuggestion: String? {
        return NSLocalizedString(message, bundle: Bundle.module, comment: message)
    }

    /// Help anchor
    var helpAnchor: String? {
        return NSLocalizedString(message, bundle: Bundle.module, comment: message)
    }
}

extension String {
    /// Create an `Error` of the current string
    var auroraError: AuroraError {
        return AuroraError(message: self)
    }
}
