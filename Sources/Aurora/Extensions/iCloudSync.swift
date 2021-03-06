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

#if !os(watchOS)
import CloudKit

private var isAuroraiCloudSyncInProgress: Bool = false

open class AuroraFrameworkiCloudSync {
    public static let shared = AuroraFrameworkiCloudSync()
    private let keyValueStore = NSUbiquitousKeyValueStore.default
    private let notificationCenter = NotificationCenter.default
    
    public init() {
        if isAuroraiCloudSyncInProgress == false {
            // Start the sync!
            self.startSync()
        }
    }
    
    open func startSync() {
        if keyValueStore.isKind(of: NSUbiquitousKeyValueStore.self) {
            notificationCenter.addObserver(
                self,
                selector: #selector(AuroraFrameworkiCloudSync.fromCloud),
                name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: nil
            )
            
            notificationCenter.addObserver(
                self,
                selector: #selector(AuroraFrameworkiCloudSync.toCloud),
                name: UserDefaults.didChangeNotification,
                object: nil
            )
            
            if keyValueStore.dictionaryRepresentation.count == 0 {
                self.toCloud()
            }
            self.fromCloud()
            
            // Say i'm syncing
            isAuroraiCloudSyncInProgress = true
        } else {
            // Say i'm not syncing :'(
            isAuroraiCloudSyncInProgress = false
            Aurora.shared.log("Can't start sync!")
        }
    }
    
    @objc
    private func fromCloud() {
        // iCloud to a Dictionary
        let dict: NSDictionary = keyValueStore.dictionaryRepresentation as NSDictionary
        
        // Disable ObServer temporary...
        notificationCenter.removeObserver(
            self,
            name: UserDefaults.didChangeNotification,
            object: nil
        )
        
        // Enumerate & Duplicate
        dict.enumerateKeysAndObjects(options: []) { (key, value, _) -> Void in
            guard let key: String = key as? String else { return }
            
            UserDefaults.standard.set(value, forKey: key)
        }
        
        // Sync!
        UserDefaults.standard.synchronize()
        
        // Enable ObServer
        notificationCenter.addObserver(
            self,
            selector: #selector(AuroraFrameworkiCloudSync.toCloud),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
        
        // Post a super cool notification.
        notificationCenter.post(
            name: Notification.Name(rawValue: "iCloudSyncDidUpdateToLatest"),
            object: nil
        )
    }
    
    @objc
    private func toCloud() {
        //        Aurora.shared.log("Going to iCloud")
        // NSUserDefaults to a dictionary
        let dict: NSDictionary = UserDefaults.standard.dictionaryRepresentation() as NSDictionary
        
        // Disable ObServer temporary...
        notificationCenter.removeObserver(
            self,
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nil
        )
        
        // Enumerate & Duplicate
        dict.enumerateKeysAndObjects { (key, value, _) -> Void in
            guard let key: String = key as? String else { return }

            keyValueStore.set(value, forKey: key as String)
        }
        
        // Sync!
        keyValueStore.synchronize()
        
        // Enable ObServer
        notificationCenter.addObserver(
            self,
            selector: #selector(AuroraFrameworkiCloudSync.fromCloud),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nil
        )
    }
    
    fileprivate func unset() {
        // Say i'm not syncing anymore
        isAuroraiCloudSyncInProgress = false
        
        // Disable ObServers
        notificationCenter.removeObserver(
            self,
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nil
        )
        
        notificationCenter.removeObserver(
            self,
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    open func sync() {
        // If not started (impossible, but ok)
        if isAuroraiCloudSyncInProgress == false {
            // Just for starting.
            self.startSync()
        } else {
            // Sync!
            keyValueStore.synchronize()
        }
    }
    
    deinit {
        // Remove it all
        self.unset()
    }
}
#endif
