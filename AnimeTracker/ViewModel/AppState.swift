//
//  AppState.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/29/23.
//

import Foundation
import CloudKit

// single source of truth for user's data, authentication tokens, screen navigation state (selected tabs, presented sheets)
@MainActor
class AppState: ObservableObject {
    @Published var isSignedInToiCloud: Bool = false
    @Published var identity: CKUserIdentity?
    @Published var isDiscoverableByEmail: Bool = false
    var username: String { return identity?.nameComponents?.givenName ?? "No username." }
    let defaults = UserDefaults.standard // used to store basic types, we use it to store user setting's preferences
    var user: User?
    
    private lazy var database: CKDatabase = container.publicCloudDatabase
    private lazy var container: CKContainer = CKContainer.default()
    let TAG = "[AppState]"
    
    init() {
        Task {
            await getiCloudStatus() // Check if user is logged into iCloud
            await requestPermission() // need this to be able to get icloud identity
            await getiCloudUserIdentity()   // Get icloud user's info (name, email, phonenumber)
            await getUser()

            // Get users record from cloudkit
            
//            await getUserRecord { [self] record in
//                Task {
//                    await updateUserInfo(record: record)
//                }
//            }
            
        }
    }

    // User needs to be signed into an iCloud Account
    func getiCloudStatus() async {
        do {
            let status = try await container.accountStatus()
            switch status {
            case .available:
                print("\(TAG) iCloud available") // user may still need to login password
                isSignedInToiCloud = true
            default:
                print("\(TAG) iCloud unavailable")
                isSignedInToiCloud = false
            }
        } catch {
            print(error)
            isSignedInToiCloud = false
        }
    }
    
    func requestPermission() async {
        do {
            let status = try await container.requestApplicationPermission([.userDiscoverability])
            switch status {
            case .granted:
                isDiscoverableByEmail = true
                print("\(TAG) User allows to be looked up by email")
            default:
                isDiscoverableByEmail = false
                print("\(TAG) User does not allow to be looked up by email")
            }
        } catch {
            print("\(TAG) Error getting user's permisison \(error)")
        }
    }
    
    func getiCloudUserIdentity() async {
        do {
            let userID = try await container.userRecordID()
            isSignedInToiCloud = true

            // important: requires permission from user to access their info
            if let identity = try await container.userIdentity(forUserRecordID: userID) {
                // can look up user's name, can't look up email unless we used email
                self.identity = identity
                print(identity.nameComponents?.givenName)
                print(identity.nameComponents?.familyName)
            } else {
                print("\(TAG) failed to get icloud identity")
            }
        } catch {
            print("\(TAG) Error calling getiCloudUser")
            isSignedInToiCloud = false
        }
    }
    
    func getUser() async {
        do {
            // 1. Get current user's record id
            let userID = try await container.userRecordID()
            
            // 2. Look for record where userID (User) == user's recordID (Users)
            let reference = CKRecord.Reference(recordID: userID, action: .none)
            let predicate = NSPredicate(format: "creatorUserRecordID == %@", reference) // userID is a CKRecord.Reference
            let query = CKQuery(recordType: .user, predicate: predicate)
            let (matchingResults, _) = try await database.records(matching: query, resultsLimit: 1)
            
            // 2. If user record exists, store it. Should only have 1
            if matchingResults.count > 0 {
                print("user exists")
                let record = try matchingResults[0].1.get()
                let user = try User(record: record)
                self.user = user
            } else {
                print("adding user")
                // 3. else, user record doesn't exist, add it
                let record = CKRecord(recordType: .user)
                record[User.RecordKey.userID] = CKRecord.Reference(recordID: userID, action: .none)
                record[.firstName] = identity?.nameComponents?.givenName
                record[.lastName] = identity?.nameComponents?.familyName
                
                try await database.save(record)
            }
            
            
        } catch {
            print("\(TAG) Error getting user record: \(error)")
        }
    }
    
//    func getUserRecord(completion: @escaping ((CKRecord) -> Void)) async {
//        do {
//            // Get user recordID
//            let userID = try await container.userRecordID()
//
//            // Get users record
//            let operation = CKFetchRecordsOperation(recordIDs: [userID])
//            operation.perRecordResultBlock = { [self] (recordID, result) in // self so we dont have to write self.user, self.TAG
//                switch result {
//                case .success(let record):
//                    print("\(TAG) Found user record")
//                    completion(record)
//                case .failure(let error):
//                    print("\(TAG) Error fetching user record: \(error)")
//                }
//            }
//
//            database.add(operation)
//        } catch {
//            print(error)
//        }
//    }
//
    func updateUserInfo(record: CKRecord) async {
        guard let identity = identity else { return }
        
        // Get user's name, last name
        if let nameParts = identity.nameComponents {
            if let firstName = nameParts.givenName {
                record[.firstName] = firstName
                print(firstName)
            }
            
            if let lastname = nameParts.familyName {
                record[.lastName] = lastname
                print(lastname)
            }
        }
                        
        do {
            let (saveResult, _) = try await database.modifyRecords(saving: [record], deleting: [], savePolicy: .changedKeys)
            
            for (_, result) in saveResult {
                switch result {
                case .success(_):
                    print("\(TAG) Updated user record sucessfully")
                case .failure(let error):
                    print("\(TAG) Error updaing anime: \(error.localizedDescription)")
                }
            }
        } catch {
            print("\(TAG) Error calling modifyRecords(): \(error.localizedDescription)")
        }
    }
}
