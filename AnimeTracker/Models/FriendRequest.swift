//
//  FriendRequest.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/24/23.
//

import Foundation
import CloudKit

struct FriendRequest: Identifiable {
    var id: String
    var senderID: CKRecord.Reference
    var receiverID: CKRecord.Reference
    
    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id)
    }
    
    init(senderID: CKRecord.Reference, receiverID: CKRecord.Reference) {
        self.id = UUID().uuidString
        self.senderID = senderID
        self.receiverID = receiverID
    }
    
    init?(record: CKRecord) {
        guard let senderID = record[.senderID] as? CKRecord.Reference,
              let receiverID = record[.receiverID] as? CKRecord.Reference else {
            return nil
        }
        
        self.id = record.recordID.recordName
        self.senderID = senderID
        self.receiverID = receiverID
    }
    
    func createFriendRequestRecord() -> CKRecord {
        let record = CKRecord(recordType: "Profile", recordID: recordID)
        record[.senderID] = self.senderID
        record[.receiverID] = self.receiverID
        return record
    }
}

extension FriendRequest {
    enum RecordKey: String {
        case senderID
        case receiverID
    }
}

extension CKRecord {
    subscript(key: FriendRequest.RecordKey) -> Any? {
        get { return self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
}
