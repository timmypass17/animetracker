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
    @Published var user: CKUserIdentity?
    
    var username: String {
        return user?.nameComponents?.givenName ?? "No username."
    }
    
    let defaults = UserDefaults.standard // used to store basic types, we use it to store user setting's preferences
    let TAG = "[AppState]"
        
    init() {
        Task {
            try await getiCloudStatus()     // Check if user is logged into iCloud
            await getiCloudUser()  // Fetch iCloud data about user
        }
    }

    // User needs to be signed into an iCloud Account
    func getiCloudStatus() async throws {
        do {
            let status = try await CKContainer.default().accountStatus()
            switch status {
            case .available:
                print("\(TAG) iCloud available") // user may still need to login password
            default:
                print("\(TAG) iCloud unavailable")
                isSignedInToiCloud = false
            }
        } catch {
            print(error)
        }

    }
    
    // note: Can discover users by record id, email, phone number. Can look up multible users at once.
    func getiCloudUser() async {
        do {
            let uid = try await CKContainer.default().userRecordID()    // get id of current user
            if let user = try await CKContainer.default().userIdentity(forUserRecordID: uid) {
                self.user = user
                isSignedInToiCloud = true
            }
            
            // user?.lookupInfo?.emailAddress (Note: can't get user's email unless we get user identity using email. we currently looking up users using userRecordID)
        } catch {
            print("\(TAG) Error calling discoveriCloudUser: \(error)")
        }
    }
    
}
