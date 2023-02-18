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
    private lazy var container: CKContainer = CKContainer.default()

    var username: String {
        return user?.nameComponents?.givenName ?? "No username."
    }
    
    let defaults = UserDefaults.standard // used to store basic types, we use it to store user setting's preferences
    let TAG = "[AppState]"
        
    init() {
        Task {
            await getiCloudStatus()     // Check if user is logged into iCloud
            await getiCloudUser()  // Fetch iCloud data about user
        }
    }

    // User needs to be signed into an iCloud Account
    func getiCloudStatus() async {
        do {
            let status = try await container.accountStatus()
            switch status {
            case .available:
                print("\(TAG) iCloud available") // user may still need to login password
            default:
                print("\(TAG) iCloud unavailable")
                isSignedInToiCloud = false
            }
        } catch {
            print(error)
            isSignedInToiCloud = false
        }

    }
    
    // note: Can discover users by record id, email, phone number. Can look up multible users at once.
    func getiCloudUser() async {
        do {
            let uid = try await container.userRecordID()
            if let user = try await container.userIdentity(forUserRecordID: uid) {
                self.user = user
                isSignedInToiCloud = true
            }
        } catch {
            print("\(TAG) Error calling getiCloudUser")
            isSignedInToiCloud = false
        }
    }
    
}
