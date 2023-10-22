//
//  Friends.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 5/1/23.
//

import Foundation
import CloudKit

struct Friends: Identifiable {
    var id: String
    var profile1: CKRecord.Reference
    var profile2: CKRecord.Reference
    
    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id)
    }
    
    init(profile1: CKRecord.Reference, profile2: CKRecord.Reference) {
        self.id = UUID().uuidString
        self.profile1 = profile1
        self.profile2 = profile2
    }
    
    init?(record: CKRecord) {
        guard let profile1 = record[.profile1] as? CKRecord.Reference,
              let profile2 = record[.profile2] as? CKRecord.Reference
        else { return nil }
        
        self.id = record.recordID.recordName
        self.profile1 = profile1
        self.profile2 = profile2
    }
}

extension Friends {
    static let sampleFriends = [
        Friends(profile1: CKRecord.Reference(record: CKRecord(recordType: "Friends"), action: .none),
                      profile2: CKRecord.Reference(record: CKRecord(recordType: "Friends"), action: .none))
    ]
    enum RecordKey: String {
        case profile1
        case profile2
    }
}

extension CKRecord {
    subscript(key: Friends.RecordKey) -> Any? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue as? CKRecordValue
        }
    }
}
