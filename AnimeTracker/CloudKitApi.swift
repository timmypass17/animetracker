//
//  CloudKitApi.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/17/23.
//

import Foundation
import CloudKit

protocol CloudKitService {
    
    func addOrUpdate(animeNode: AnimeNode) async

//    func fetchAnimesFromCloudKit() async -> [AnimeNode]
    
    func deleteAnime(animeNode: AnimeNode) async
    
    func fetchRecords(cursor: CKQueryOperation.Cursor?, completion: @escaping (([CKRecord]) -> Void))
    
    func fetchRecordsInBatches(isFirstFetch: Bool, _ cursor: CKQueryOperation.Cursor?, completionHandler handler: @escaping (_ records: [CKRecord]?, _ cursor: CKQueryOperation.Cursor?) -> (Void))

}
