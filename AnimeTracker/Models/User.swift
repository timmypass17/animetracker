//
//  User.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/21/23.
//

import Foundation
import CloudKit

struct User: Identifiable {
    var recordName: String
    var userID: CKRecord.Reference
    var firstName: String
    var lastName: String
    
    var id: String { recordName } // identifiable
    
    init(userID: CKRecord.Reference, firstName: String, lastName: String) {
        self.recordName = UUID().uuidString
        self.userID = userID
        self.firstName = firstName
        self.lastName = lastName
    }
    
    // convert existing record to User object
    init(record: CKRecord) throws {
        // unwarp record's fields
        guard let userID = record[User.RecordKey.userID] as? CKRecord.Reference else { throw RecordError.missingKey(.userID) }
        guard let firstName = record[.firstName] as? String else { throw RecordError.missingKey(.firstName) }
        guard let lastName = record[.lastName] as? String else { throw RecordError.missingKey(.lastName) }
        
        self.recordName = record.recordID.recordName
        self.userID = userID
        self.firstName = firstName
        self.lastName = lastName
    }
    
    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: recordName)
    }
    
    // Return a record object using self
    var record: CKRecord {
        let record = CKRecord(recordType: .user, recordID: recordID)
        record[User.RecordKey.userID] = userID
        record[.firstName] = firstName
        record[.lastName] = lastName
        
        return record
    }
}

extension User {
    enum RecordKey: String {
        case userID
        case firstName
        case lastName
    }
    
    struct RecordError: LocalizedError {
        var localizedDescription: String
        
        static func missingKey(_ key: RecordKey) -> RecordError {
            RecordError(localizedDescription: "Missing required key \(key.rawValue)")
        }
    }
}

extension User {
    static let dummyReference: CKRecord.Reference = CKRecord.Reference(recordID: CKRecord.ID(recordName: "DummyID"), action: .none)
    static let sampleUsers: [User] = [
        User(userID: dummyReference, firstName: "Timmy", lastName: "Nguyen"),
        User(userID: dummyReference, firstName: "Kitty", lastName: "Nguyen")
    ]
}
