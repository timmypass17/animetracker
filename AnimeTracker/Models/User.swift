//
//  User.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/21/23.
//

import Foundation
import CloudKit

struct User {
    var record: CKRecord = CKRecord(recordType: User.RecordKey.recordType.rawValue)
    var name: String?
    var email: String?
}

extension User {
    enum RecordKey: String {
        case recordType = "Users"
        case friends
    }
}

extension User {
    static let sampleUsers: [User] = [
        User(name: "Timmy Nguyen", email: "email123@gmail.com")
    ]
}
