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
#if canImport(UIKit) && !os(watchOS)
import UIKit

public extension UIApplication {
    /// Clear the cache of the launchscreen
    func clearLaunchScreenCache() {
        do {
            try FileManager.default.removeItem(
                atPath: NSHomeDirectory() + "/Library/SplashBoard"
            )
        } catch {
            Aurora.shared.log(
                "Failed to delete launch screen cache with error: \(error)"
            )
        }
    }

    /// The layout direction of the user interface.
    ///
    /// This method specifies the general user interface layout flow direction. \
    /// See UIUserInterfaceLayoutDirection for a description of the constants returned by this property.
    var userInterfaceRightToLeft: Bool {
        return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
    }

    #if !os(watchOS) && !os(visionOS)
    /// Get the top most (key) window
    var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    #endif
}

@available(iOS 10.0, tvOS 10.0, *)
public extension UIApplication {
    /// Open app settings
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        open(url, options: [:], completionHandler: nil)
    }

    /// Open app review page
    /// - Parameter url: `URL` App page url finishing with `write-review`
    func openAppStoreReviewPage(_ url: URL) {
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}

#if os(iOS)
public extension UIApplication {
    /// Get the UIApplication delegate
    /// - Parameter type: The application delegate type.
    /// - Returns: The app delegate found casted in the right type. If none of this type found then returns nil.
    static func delegate<T: UIApplicationDelegate>(_ type: T.Type) -> T? {
        UIApplication.shared.delegate as? T
    }

}
#endif
#endif
