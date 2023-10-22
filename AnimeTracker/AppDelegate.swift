//
//  AppDelegate.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/20/23.
//

import Foundation
import SwiftUI
import CloudKit

class AppDelegate: NSObject,/* UIResponder */ UIApplicationDelegate, UNUserNotificationCenterDelegate, ObservableObject {
    
    @Published var newPendingRequest: FriendRequest? = nil
    
    private lazy var container: CKContainer = CKContainer.default()
    private lazy var database: CKDatabase = container.publicCloudDatabase
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Task {
            // Pop up shows only once (to show again, delete and reinstall app). Still returns a value after accepting.
            UNUserNotificationCenter.current().delegate = self
            if try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                // Handle success
                UIApplication.shared.registerForRemoteNotifications()
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
            
//             Delete subscriptions
//            let operation = CKModifySubscriptionsOperation(subscriptionsToSave: nil, subscriptionIDsToDelete: subscriptions.map { $0.subscriptionID })
//            operation.qualityOfService = .utility
//            CKContainer.default().publicCloudDatabase.add(operation)

        }
        
        return true
    }
    
    // Function called when notification was triggered (foreground or background).
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("didReceiveRemoteNotification")
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else { return completionHandler(.failed) }
        print(notification)
        
        // Check notification type
        if notification.notificationType == .query, let result = notification as? CKQueryNotification {
            // Check which subscription was triggered
            if result.subscriptionID == .newFriendRequestSubscription {
                // Extract data from notification payload (e.g. result.recordFields?["animeTitle"] as! String)
                if let recordID = result.recordID {
                    Task {
                        print("Handle friend request")
                        await handleFriendRequest(recordID: recordID)
                    }
                }
            } else {
                print("Unknown subscription id")
            }
        }
        
        return completionHandler(.newData)
    }

    func handleFriendRequest(recordID: CKRecord.ID) async {
        do {
            // Fetch friend request record
            let senderID = CKRecord.Reference(recordID: recordID, action: .none)
            let userID = try await container.userRecordID()
            let receiverID = CKRecord.Reference(recordID: userID, action: .none)
            let predicate = NSPredicate(format: "senderID == %@ AND receiverID == %@", senderID, receiverID)
            let query = CKQuery(recordType: "FriendRequest", predicate: predicate)
            let (results, _) = try await database.records(matching: query, resultsLimit: 1)
            
            // This fails because record is not created by time user receives this notification so there is not record to fetch
            if let record = try results.first?.1.get() {
                // Handle successfully getting friend request
                print("Successfully got friend request")
                self.newPendingRequest = FriendRequest(record: record)
            } else {
                print("Friend request not found")
            }
            
        } catch {
            print("Erroring fetching friend request record: \(error)")
        }
    }
    
    func createSubscriptionIfNeeded() async throws {
        
        await createFriendRequestSubscriptionIfNeeded()
//        await createNewAnimeAddedSubscriptionIfNeeded()
    }
    
    func createFriendRequestSubscriptionIfNeeded() async {
//        // TODO: Remove later, just for debugging
//        UserDefaults.standard.setValue(false, forKey: "didCreateFriendRequestSubscription")

        // Only proceed if you need to create the subscription.
        guard !UserDefaults.standard.bool(forKey: "didCreateFriendRequestSubscription") else {
            print("Friend request subscription created already.")
            return
        }
        
        do {
            let userID = try await CKContainer.default().userRecordID()
            let reference = CKRecord.Reference(recordID: userID, action: .none)
            let predicate = NSPredicate(format: "\(FriendRequest.RecordKey.receiverID.rawValue) == %@", reference)
            let subscription = CKQuerySubscription(
                recordType: "FriendRequest",
                predicate: predicate,
                subscriptionID: .newFriendRequestSubscription,
                options: .firesOnRecordCreation
            )
            
            let notificationInfo = CKSubscription.NotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            
            notificationInfo.title = "You have a new friend request"
            notificationInfo.alertBody = "Check your friend request!"
            subscription.notificationInfo = notificationInfo
            
            let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)
            
            
            operation.modifySubscriptionsResultBlock = { result in
                switch result {
                case .success():
                    // Record that the system successfully creates the subscription
                    // to prevent unnecessary trips to the server in later launches.
                    UserDefaults.standard.setValue(true, forKey: "didCreateFriendRequestSubscription")
                    print("Saved friend request subscription")
                case .failure(let error):
                    // Handle the error.
                    print("Error saving friend request subscription: \(error)")
                    return
                }
            }
            
            operation.qualityOfService = .utility
            CKContainer.default().publicCloudDatabase.add(operation) // monitor changes in public database
            
        } catch{
            print("Erroring creating friend request subcription: \(error)")
        }
    }
    
    func createNewAnimeAddedSubscriptionIfNeeded() async {
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
//        CKContainer.default().publicCloudDatabase.add(operation)
        CKContainer.default().privateCloudDatabase.add(operation)
    }
}

extension CKSubscription.ID {
    static let newFriendRequestSubscription = "new-friend-request"
}
