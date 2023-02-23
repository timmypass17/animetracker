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
    private lazy var database: CKDatabase = container.publicCloudDatabase
    private lazy var container: CKContainer = CKContainer.default()
    let defaults = UserDefaults.standard // used to store basic types, we use it to store user setting's preferences
    let TAG = "[AppState]"
    
    var user: User?
    
    init() {
        Task {
            await getiCloudStatus() // Check if user is logged into iCloud
            await requestPermission() //
            await getiCloudUser()   // Get icloud user's info (name, email, phonenumber)
            await getUserRecord()   // Get users record from cloudkit
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
    
    func getiCloudUser() async {
        do {
            let userID = try await container.userRecordID()
            isSignedInToiCloud = true

            // important: requires permission from user to access their info
            if let identity = try await container.userIdentity(forUserRecordID: userID) {
                // can look up user's name, can't look up email unless we used email
                self.identity = identity
            } else {
                print("\(TAG) failed to get icloud identity")
            }
        } catch {
            print("\(TAG) Error calling getiCloudUser")
            isSignedInToiCloud = false
        }
    }
    
    func getUserRecord() async {
        do {
            // Get user recordID
            let userID = try await container.userRecordID()
            
            // Get users record
            let operation = CKFetchRecordsOperation(recordIDs: [userID])
            operation.perRecordResultBlock = { [self] (recordID, result) in // self so we dont have to write self.user, self.TAG
                switch result {
                case .success(let record):
                    print("\(TAG) Found user record")
                    user = User(record: record)
                    
                    // Get user's name
                    if let identity = identity {
                        if let nameParts = identity.nameComponents, let name = nameParts.givenName {
                            user?.name = name
                            print(name)
                        }
                        // Can't access user's email unless we got identity using email (we used id)
//                        if let lookupInfo = identity.lookupInfo, let email = lookupInfo.emailAddress {
//                            user?.email = email
//                            print(email)
//                        }
                        
                    }
                    
//                    guard let friends = record[User.RecordKey.friends] as? [CKRecord.Reference]
                    else {
                        print("\(TAG) failed to get friends list")
                        return
                    }
                    
                case .failure(let error):
                    print("\(TAG) Error fetching user record: \(error)")
                }
            }
            
            operation.fetchRecordsResultBlock = { [self] result in
                switch result {
                case .success(_):
                    print("\(TAG) Successfully finished getting user record")
                case.failure(let error):
                    print("\(TAG) Failed to get user record: \(error)")
                }
            }
            
            database.add(operation)
        } catch {
            print(error)
        }
    }
}
