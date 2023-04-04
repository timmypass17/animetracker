//
//  AnimeProgress.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 3/29/23.
//

import Foundation
import CloudKit

struct AnimeProgress: Codable {
    var id: String
    var animeID: Int
    var animeType: AnimeType
    var seen: Int
    var creationDate: Date
    var modificationDate: Date
    
    init(id: String = UUID().uuidString, animeID: Int = 0, animeType: AnimeType = .anime, seen: Int = 0, creationDate: Date = Date(), modificationDate: Date = Date()) {
        self.id = id
        self.animeID = animeID
        self.animeType = animeType
        self.seen = seen
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
    
    init(record: CKRecord) {
        self.id = record.recordID.recordName
        self.animeID = record[.animeID] as? Int ?? 0
        self.animeType = AnimeType(rawValue: record[.animeType] as? String ?? "") ?? .anime
        self.seen = record[.seen] as? Int ?? 0
        self.creationDate = record.creationDate!
        self.modificationDate = record.modificationDate!
    }
    
    
    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id)
    }
    
    var record: CKRecord {
        let record = CKRecord(recordType: .animeProgress, recordID: recordID)
        record[.animeID] = animeID
        record[.animeType] = animeType.rawValue // can't store enum directly, unwrap it
        record[.seen] = seen
        return record
    }
    
}

extension AnimeProgress {
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
    subscript(key: AnimeProgress.RecordKey) -> Any? {
        get { return self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
}

extension CKRecord.RecordType {
    static let animeProgress = "AnimeProgress"
}
