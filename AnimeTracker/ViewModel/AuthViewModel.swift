//
//  AuthViewModel.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/23/22.
//

import Foundation
import CloudKit

// Note: @MainActor automatically dispatch UI updates on the main queue.
//       Removes need to manually call DisptachQueue.main.async{} when updating views asynchronously.
// Why? UI can only be updated on the main queue. So updating views on a background queue is bad.

@MainActor
class AuthViewModel: ObservableObject {
    @Published var showAlert = false

    // delete later
    @Published var isSignedInToiCloud: Bool = false
    @Published var permissionStatus: Bool = false
    @Published var error: String = ""
    @Published var userName: String = ""
    
    init() {
        Task {
            await getiCloudStatus()     // Check if user is logged into iCloud
            await discoveriCloudUser()  // Fetch iCloud data about user
        }
    }
    
    // User needs to be signed into an iCloud Account
    private func getiCloudStatus() async {
        do {
            let status = try await CKContainer.default().accountStatus()
            switch status {
            case .couldNotDetermine:
                self.error = CloudKitError.iCloudAccountNotDetermined.rawValue
                self.showAlert = true
            case .available:
                self.isSignedInToiCloud = true // updating change on background thread, @MainActor fixes that
                self.showAlert = false
            case .restricted:
                self.error = CloudKitError.iCloudAccountRestricted.rawValue
                self.showAlert = true
            case .noAccount:
                self.error = CloudKitError.iCloudAccountNotFound.rawValue
                self.showAlert = true
            case .temporarilyUnavailable:
                self.error = CloudKitError.iCloudAccountUnavailable.rawValue
                self.showAlert = true
            @unknown default:
                self.error = CloudKitError.iCloudUnknown.rawValue
                self.showAlert = true
            }
        } catch {
            print("Error calling getiCloudStatus: \(error)")
        }
    }
    
    enum CloudKitError: String, LocalizedError {
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountNotFound
        case iCloudAccountUnavailable
        case iCloudUnknown
    }
    
    // note: Can discover users by record id, email, phone number. Can look up multible users at once.
    func discoveriCloudUser() async {
        do {
            let uid = try await CKContainer.default().userRecordID()    // get id of current user
            let user = try await CKContainer.default().userIdentity(forUserRecordID: uid)   // get user's iCloud info using user's id
            
            if let name = user?.nameComponents?.givenName { // unwrap optional user if let
                self.userName = name
            }
            
            // user?.lookupInfo?.emailAddress (Note: can't get user's email unless we get user identity using email. we currently looking up users using userRecordID)
        } catch {
            print("Error calling discoveriCloudUser: \(error)")
        }
    }
}
