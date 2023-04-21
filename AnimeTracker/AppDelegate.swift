//
//  AppDelegate.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/20/23.
//

import Foundation
import SwiftUI
import CloudKit

class AppDelegate: NSObject,/* UIResponder */ UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Task {
            // Pop up shows only once (to show again, delete and reinstall app). Still returns a value after accepting.
            if try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                // Handle success
                UIApplication.shared.registerForRemoteNotifications()
//                UNUserNotificationCenter.current().delegate = self
                try? await createSubscriptionIfNeeded()
            }
            
//            // print user defaults
//            for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
//                print("\(key) = \(value) \n")
//            }
//
            // check all subscriptions
            var database = CKContainer.default().publicCloudDatabase
            var subscriptions = try await database.allSubscriptions()
            
            for subscriptionObject in subscriptions {
                var subscription: CKSubscription = subscriptionObject as CKSubscription
                print("Subscription: \(subscription.subscriptionID)")
            }
        }
        return true
    }

    // Function called when notification was triggered. Do something with the records.
    // App in foreground: No banner, this functions runs
    // App in background: Banner, functions runs when user taps banner or opens app
    // note: notfications arent used to show WHAT changed but that something has changed.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        print("receive notification")
        
        // Extract data from push notification
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject]) {
            // Check if notification was query
            if notification.notificationType == .query,
               let result = notification as? CKQueryNotification {
                
                // if result.subscriptionID == ... { }
                
                // Unwrap payload data
                //            print(result.recordFields?["animeTitle"] as! String)

                print(result.recordID?.recordName)
            }
        }
        
        return completionHandler(.newData)
    }
    
    func createSubscriptionIfNeeded() async throws {
        // TODO: Remove later, just for debugging
        UserDefaults.standard.setValue(false, forKey: "didCreateQuerySubscription")
        
        // Only proceed if you need to create the subscription.
        guard !UserDefaults.standard.bool(forKey: "didCreateQuerySubscription") else {
            print("Susbcription created already.")
            return
        }
                        
        // Define a predicate that matches records with a tags field
        // that contains the word 'Swift'.
//        let predicate = NSPredicate(format: "\(Progress.RecordKey.animeType.rawValue) == %@", "anime")
        let predicate = NSPredicate(value: true)
                
        // Create a subscription and scope it to the 'FeedItem' record type.
        // Provide a unique identifier for the subscription and declare the
        // circumstances for invoking it.
        let subscription = CKQuerySubscription(recordType: "Progress",
                                               predicate: predicate,
                                               subscriptionID: "new-anime-added",
                                               options: .firesOnRecordCreation)
        
                
//        // Configure the notification so that the system delivers it silently
//        // and, therefore, doesn't require permission from the user.
//        let notificationInfo = CKSubscription.NotificationInfo()
//        notificationInfo.shouldSendContentAvailable = true
//        subscription.notificationInfo = notificationInfo
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        // Visible banner
        notificationInfo.title = "New anime added"
        
        notificationInfo.alertLocalizationKey = "%1$@"
        notificationInfo.alertLocalizationArgs = [Progress.RecordKey.animeID.rawValue]
        
        notificationInfo.desiredKeys = [Progress.RecordKey.animeID.rawValue]
        
//        notificationInfo.title = "New anime added"
//        notificationInfo.alertBody = "A new anime title"
//        notificationInfo.soundName = "default"
//
//        notificationInfo.desiredKeys = [Progress.RecordKey.]
        subscription.notificationInfo = notificationInfo
                
        // Save the subscription to the server.
        let operation = CKModifySubscriptionsOperation(
            subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)
        
        operation.modifySubscriptionsResultBlock = { result in
            switch result {
            case .success():
                // Record that the system successfully creates the subscription
                // to prevent unnecessary trips to the server in later launches.
                UserDefaults.standard.setValue(true, forKey: "didCreateQuerySubscription")
                print("Saved subscription")
            case .failure(let error):
                // Handle the error.
                print("Error saving subscription: \(error)")
                return
            }
        }
                
        // Set an appropriate QoS and add the operation to the private
        // database's operation queue to execute it.
        operation.qualityOfService = .utility
        CKContainer.default().publicCloudDatabase.add(operation)
//        CKContainer.default().privateCloudDatabase.add(operation)
    }
}

