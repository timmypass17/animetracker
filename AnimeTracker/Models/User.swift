//
//  User.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/21/23.
//

import Foundation
import CloudKit

struct User {
//    var record: CKRecord = CKRecord(recordType: .user)
    var id: String
    // users can look up other users on firstName or userName
    var firstName: String
    var lastName: String
    var username: String?
    // cant get email
    
    init(firstName: String, lastName: String, username: String? = nil) {
        self.id = UUID().uuidString
        self.firstName = firstName
        self.lastName = lastName
    }
    
    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id)
    }
    
    func createUserRecord(firstName: String, lastName: String, userName: String?) -> CKRecord {
        let record = CKRecord(recordType: .user, recordID: recordID)
        record[.firstName] = firstName
        record[.lastName] = lastName
        record[.username] = username
        
        return record
    }
}

extension User {
    enum RecordKey: String {
        case firstName
        case lastName
        case username
    }
}

extension User {
    static let sampleUsers: [User] = [
        User(firstName: "Timmy", lastName: "Nguyen", username: "timmypass21")
    ]
}
