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
    var profileID: CKRecord.Reference // Profile of sender. So we make less trips to cloudkit and easier to fetch and display
    
    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id)
    }
    
    init(senderID: CKRecord.Reference, receiverID: CKRecord.Reference, profileID: CKRecord.Reference) {
        self.id = UUID().uuidString
        self.senderID = senderID
        self.receiverID = receiverID
        self.profileID = profileID
    }
    
    init?(record: CKRecord) {
        guard let senderID = record[.senderID] as? CKRecord.Reference,
              let receiverID = record[.receiverID] as? CKRecord.Reference,
              let profileID = record[.profileID] as? CKRecord.Reference
        else {
            return nil
        }
        
        self.id = record.recordID.recordName
        self.senderID = senderID
        self.receiverID = receiverID
        self.profileID = profileID
    }
    
    func createFriendRequestRecord() -> CKRecord {
        let record = CKRecord(recordType: "Profile", recordID: recordID)
        record[.senderID] = self.senderID
        record[.receiverID] = self.receiverID
        record[.profileID] = self.profileID
        return record
    }
}

extension FriendRequest {
    static let sampleFriendRequests = [
        FriendRequest(senderID: CKRecord.Reference(record: CKRecord(recordType: "FriendRequest"), action: .none),
                      receiverID: CKRecord.Reference(record: CKRecord(recordType: "FriendRequest"), action: .none),
                     profileID: CKRecord.Reference(record: CKRecord(recordType: "FriendRequest"), action: .none))
    ]
    enum RecordKey: String {
        case senderID
        case receiverID
        case profileID
    }
}

extension CKRecord {
    subscript(key: FriendRequest.RecordKey) -> Any? {
        get { return self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
}
