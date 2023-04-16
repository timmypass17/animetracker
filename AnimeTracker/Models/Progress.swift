//
//  AnimeProgress.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 3/29/23.
//

import Foundation
import CloudKit

struct Progress: Codable {
    var id: String
    var animeID: Int
    var animeType: WeebItemType
    var seen: Int
    var creationDate: Date
    var modificationDate: Date
    
    init(animeID: Int = 0, animeType: WeebItemType = .anime, seen: Int = 0) {
        self.id = UUID().uuidString
        self.animeID = animeID
        self.animeType = animeType
        self.seen = seen
        self.creationDate = Date()
        self.modificationDate = Date()
    }
    
    init?(record: CKRecord) {
        guard let animeID = record[.animeID] as? Int,
              let animeTypeString = record[.animeType] as? String,
              let animeType = WeebItemType(rawValue: animeTypeString),
              let seen = record[.seen] as? Int,
              let creationDate = record.creationDate,
              let modificationDate = record.modificationDate
        else { return nil }
        
        self.id = record.recordID.recordName
        self.animeID = animeID
        self.animeType = animeType
        self.seen = seen
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
    
    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id)
    }
    
    var record: CKRecord {
        let record = CKRecord(recordType: .progress, recordID: recordID)
        record[.animeID] = animeID
        record[.animeType] = animeType.rawValue // can't store enum directly, unwrap it
        record[.seen] = seen
        return record
    }
    
}

extension Progress {
    enum RecordKey: String {
        case seen
        case animeID
        case animeType
    }
    
    struct RecordError: LocalizedError {
        var localizedDescription: String
        
        static func missingKey(_ key: RecordKey) -> RecordError {
            RecordError(localizedDescription: "Missing required key \(key.rawValue)")
        }
    }
}

extension CKRecord {
    subscript(key: Progress.RecordKey) -> Any? {
        get { return self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
}

extension CKRecord.RecordType {
    static let progress = "Progress"
}
