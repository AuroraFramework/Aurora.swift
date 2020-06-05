// $$HEADER$$

#if os(iOS) || os(tvOS)
#if canImport(UIKit)
import Foundation
import UIKit

extension Aurora {
    /// Calls action when a screen shot is taken
    public static func onScreenshot(_ action: @escaping () -> Void) {
        let mainQueue = OperationQueue.main
        _ = NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
        object: nil,
        queue: mainQueue
        ) { _ in
            // executes after screenshot
            action()
        }
    }
    
    /// Is the screen currently being recorded?
    var isScreenRecording: Bool {
        return UIScreen.screens.filter { $0.isCaptured }.count > 0
    }
}
#endif
#endif
