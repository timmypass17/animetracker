//
//  FriendShipRequests.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/27/23.
//

import Foundation
import CloudKit

struct Friendship {
    var recordName: String // record name
    var senderID: CKRecord.Reference
    var recipientID: CKRecord.Reference
    var status: Friendship.Status
    
    init(userID: CKRecord.Reference, friendID: CKRecord.Reference, status: Friendship.Status) {
        self.recordName = UUID().uuidString
        self.senderID = userID
        self.recipientID = friendID
        self.status = status
    }
    
    init(record: CKRecord) throws {
        // unwarp record's fields
        guard let userID = record[Friendship.RecordKey.senderID] as? CKRecord.Reference else { throw RecordError.missingKey(.senderID) }
        guard let friendID = record[Friendship.RecordKey.recipientID] as? CKRecord.Reference else { throw RecordError.missingKey(.recipientID) }
        guard let status = record[Friendship.RecordKey.status] as? String else { throw RecordError.missingKey(.status) }
        guard let friendshipStatus = Friendship.Status(rawValue: status) else { throw RecordError.missingKey(.status) }
        
        self.recordName = record.recordID.recordName
        self.senderID = userID
        self.recipientID = friendID
        self.status = friendshipStatus
    }
    
    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: recordName)
    }
    
    enum Status: String {
        case accepted, pending, rejected
    }
}

extension Friendship {
    enum RecordKey: String {
        case senderID
        case recipientID
        case status
    }
    
    struct RecordError: LocalizedError {
        var localizedDescription: String
        
        static func missingKey(_ key: RecordKey) -> RecordError {
            RecordError(localizedDescription: "Missing required key \(key.rawValue)")
        }
    }
    
    static var sampleFriendShipRequest = Friendship(userID: User.dummyReference, friendID: User.dummyReference, status: .pending)
}
