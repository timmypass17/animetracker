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
    var userID: CKRecord.ID?
    
    let defaults = UserDefaults.standard // used to store basic types, we use it to store user setting's preferences
    private lazy var database: CKDatabase = container.publicCloudDatabase
    private lazy var container: CKContainer = CKContainer.default()
    let TAG = "[AppState]"
    
    init() {
        Task {
            await getiCloudStatus() // Check if user is logged into iCloud
            await getUser()
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

    func getUser() async {
        do {
            userID = try await container.userRecordID()
        } catch {
            print("\(TAG) Error getting user record: \(error)")
        }
    }
}
