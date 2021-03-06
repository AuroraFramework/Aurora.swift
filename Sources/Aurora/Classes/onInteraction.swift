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

/// <#Description#>
enum AssociationPolicy {
    case assign
    case retainNonatomic
    case copyNonatomic
    case retain
    case copy
    
    var rawValue: objc_AssociationPolicy {
        switch self {
        case .assign:
            return .OBJC_ASSOCIATION_ASSIGN
        case .retainNonatomic:
            return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        case .copyNonatomic:
            return .OBJC_ASSOCIATION_COPY_NONATOMIC
        case .retain:
            return .OBJC_ASSOCIATION_RETAIN
        case .copy:
            return .OBJC_ASSOCIATION_COPY
        }
    }
}

/// <#Description#>
final class ObjectAssociation<T: Any> {
    private let policy: AssociationPolicy
    
    init(policy: AssociationPolicy = .retainNonatomic) {
        self.policy = policy
    }
    
    subscript(index: AnyObject) -> T? {
        get {
            // Force-cast is fine here as we want it to fail loudly if we don't use the correct type.
            // swiftlint:disable:next force_cast
            objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T?
        }
        set {
            objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy.rawValue)
        }
    }
}

#if canImport(UIKit) && !os(watchOS)
import UIKit

public extension UIControl {
    /// .onInteraction
    ///
    /// Do something on interaction
    ///
    /// - Parameters:
    ///   - controlEvents: For which control events?
    ///   - action: Which action needs to be executed.
    ///
    /// ​‎‎
    ///
    /// **Example**
    ///
    ///     myControlElement.onInteraction { sender in
    ///        print(sender)
    ///     }
    func onInteraction(
        for controlEvents: UIControl.Event = .primaryActionTriggered,
        action: @escaping (AnyObject) -> Void
    ) {
        /// <#Description#>
        let helper = UIControlHelper(
            attachTo: self,
            closure: action
        )
        
        addTarget(
            helper,
            action: #selector(UIControlHelper.invoke),
            for: controlEvents
        )
    }
}

/// <#Description#>
public class UIControlHelper {
    /// <#Description#>
    let closure: (AnyObject) -> Void
    
    /// <#Description#>
    /// - Parameters:
    ///   - attachTo: <#attachTo description#>
    ///   - closure: <#closure description#>
    public init(attachTo: AnyObject, closure: @escaping (AnyObject) -> Void) {
        self.closure = closure
        objc_setAssociatedObject(
            attachTo,
            "[\(arc4random())]",
            self,
            .OBJC_ASSOCIATION_RETAIN
        )
    }
    
    /// <#Description#>
    /// - Parameter sender: <#sender description#>
    @objc
    func invoke(sender: AnyObject) {
        closure(sender)
    }
}
#endif

#if canImport(AppKit)
import AppKit

// Thanks @sindresorhus
// see https://gist.github.com/sindresorhus/3580ce9426fff8fafb1677341fca4815
// renamed onAction to onInteraction
public extension NSControl {
    /// <#Description#>
    typealias ActionClosure = ((NSControl) -> Void)
    
    /// <#Description#>
    private struct AssociatedKeys {
        static let onActionClosure = ObjectAssociation<ActionClosure>()
    }
    
    /// <#Description#>
    /// - Parameter sender: <#sender description#>
    @objc
    private func callClosure(_ sender: NSControl) {
        onInteraction?(sender)
    }
    
    /// .onInteraction
    ///
    /// Do something on interaction
    ///
    /// - Parameters:
    ///   - controlEvents: For which control events?
    ///   - action: Which action needs to be executed.
    ///
    /// ​‎‎
    ///
    /// **Example**
    ///
    ///     myControlElement.onInteraction { sender in
    ///        print(sender)
    ///     }
    var onInteraction: ActionClosure? {
        get {
            return AssociatedKeys.onActionClosure[self]
        }
        set {
            AssociatedKeys.onActionClosure[self] = newValue
            action = #selector(callClosure)
            target = self
        }
    }
}
#endif
