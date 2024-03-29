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
#if canImport(UIKit) && os(iOS)
import UIKit

/// Fixes the issue for screens being to small and that inputfields will be gone!
///
/// Fixes the issue for screens being to small and that inputfields will be gone!
///
/// .
///
/// **usage:**
///
///     Aurora.keyboardHandler(forViewController: self)
///
/// made for views which uses autolayout.
///
/// Please note, it's a simple solution, so please don't expect micacles.
///
/// _WARNING, do not use if the input field is on the upper-part of the screen,
/// there's no protection for such things built-in._
public class AuroraKeyboardHandler {
    /// Fixes the issue for screens being to small and that inputfields will be gone!
    ///
    ///     keyboardHandler(forViewController: self)
    ///
    /// - Parameter forViewController: Viewcontroller (mostly `self`)
    @discardableResult
    public init(forViewController: UIViewController) {
        // swiftlint:disable:previous function_body_length
        // Add a notification handler for 'keyboard will show'
        _ = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { (notification) in
            // force set viewcontroller frame to 0
            // (needed if a previous keyboard was smaller)
            forViewController.view.frame.origin.y = 0

            // get frame key
            let key = UIResponder.keyboardFrameEndUserInfoKey

            // Extract the keyboard size
            if let keyboardSize = (notification.userInfo?[key] as? NSValue)?.cgRectValue {
                // Check if the frame is 0
                if forViewController.view.frame.origin.y == 0 {
                    UIView.animate(withDuration: 0.1, animations: { () -> Void in
                        // Move the frame up
                        forViewController.view.frame.origin.y -= (
                            // Keyboard height
                            keyboardSize.height
//                            // + Safe area insets (bottom)
//                            + forViewController.view.safeAreaInsets.bottom
                        )

                        // Ask to renew the layout (if needed)
                        forViewController.view.layoutIfNeeded()
                        forViewController.view.setNeedsDisplay()

                        if #available(iOS 15.0, *) {
                            let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow})
                            window?.windowScene?.keyWindow?.layoutIfNeeded()
                        } else {
                            UIApplication.shared.keyWindow?.layoutIfNeeded()
                        }
                    })
                }
            }
        }

        // Add a notification handler for 'keyboard will hide'
        _ = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { (notification) in
            // get the frame
            let key = UIResponder.keyboardFrameEndUserInfoKey

            // Extract the keyboard size
            if let keyboardSize = (notification.userInfo?[key] as? NSValue)?.cgRectValue {
                // Check if the frame is not 0
                if forViewController.view.frame.origin.y > 0 {
                    UIView.animate(withDuration: 0.1, animations: { () -> Void in
                        // Move the frame down
                        forViewController.view.frame.origin.y += (
                            // Keyboard height
                            keyboardSize.height
//                            // - Safe area insets (bottom)
//                            - forViewController.view.safeAreaInsets.bottom
                        )

                        // Ask to renew the layout (if needed)
                        forViewController.view.layoutIfNeeded()
                        forViewController.view.setNeedsDisplay()

                        if #available(iOS 15.0, *) {
                            let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow})
                            window?.windowScene?.keyWindow?.layoutIfNeeded()
                        } else {
                            UIApplication.shared.keyWindow?.layoutIfNeeded()
                        }
                    })
                } else {
                    UIView.animate(withDuration: 0.1, animations: { () -> Void in
                        forViewController.view.frame.origin.y = (
                            0 - forViewController.view.safeAreaInsets.bottom
                        )

                        // Ask to renew the layout (if needed)
                        forViewController.view.layoutIfNeeded()
                        forViewController.view.setNeedsDisplay()

                        if #available(iOS 15.0, *) {
                            let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow})
                            window?.windowScene?.keyWindow?.layoutIfNeeded()
                        } else {
                            UIApplication.shared.keyWindow?.layoutIfNeeded()
                        }
                    })
                }
            }
        }
    }
}
#endif
