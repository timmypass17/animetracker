//
//  Profile.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/22/23.
//

import Foundation
import CloudKit

struct Profile: Identifiable {
    var id: String
    var username: String
    var profileImage: CKAsset?
    var userID: CKRecord.Reference // User record
    
    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id)
    }
    
    init(username: String, profileImage: CKAsset? = nil, userID: CKRecord.Reference) {
        self.id = UUID().uuidString
        self.username = username
        self.profileImage = profileImage
        self.userID = userID
    }
    
    // Extract data from record
    init?(record: CKRecord) {
        guard let username = record[.username] as? String,
              let profileImage = record[.profileImage] as? CKAsset?,
              let userID = record[.userID] as? CKRecord.Reference else {
            return nil
        }
        
        self.id = record.recordID.recordName
        self.username = username
        self.profileImage = profileImage
        self.userID = userID
    }
    
    func createProfileRecord() async throws -> CKRecord {
        let record = CKRecord(recordType: "Profile", recordID: recordID)
        record[.username] = self.username
        record[.profileImage] = self.profileImage
        record[.userID] = try await CKContainer.default().userRecordID()
        
        return record
    }
}


extension Profile {
    
    func usernameString() -> String {
        let usernameParts = username.components(separatedBy: "#")
        return usernameParts.count > 0 ? usernameParts[0] : "usernameNotFound"
    }
    
    func usernameDigits() -> String {
        let usernameParts = username.components(separatedBy: "#")
        return usernameParts.count > 1 ? usernameParts[1] : "digitsNotFound"
    }
    
    static let sampleProfiles = [
        Profile(username: "timby", userID: CKRecord.Reference(record: CKRecord(recordType: "Profile"), action: .none)),
        Profile(username: "hina", userID: CKRecord.Reference(record: CKRecord(recordType: "Profile"), action: .none)),
        Profile(username: "dudu bear", userID: CKRecord.Reference(record: CKRecord(recordType: "Profile"), action: .none)),
        Profile(username: "bubu bear", userID: CKRecord.Reference(record: CKRecord(recordType: "Profile"), action: .none))
    ]
    
    enum RecordKey: String {
        case username, profileImage, userID
    }
}

extension CKRecord {
    subscript(key: Profile.RecordKey) -> Any? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue as? CKRecordValue
        }
    }
}
