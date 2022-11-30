//
//  HomeViewModel.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import Foundation
import CloudKit

enum ViewMode: String, CaseIterable, Identifiable {
    case watching, completed, planning
    var id: Self { self } // forEach
}

enum SearchMode: String, CaseIterable, Identifiable {
    case all, anime, manga
    var id: Self { self } // forEach
}

@MainActor // to automatically dispatch UI updates on the main queue. Same as doing DispatchQueue.main.async{}
class HomeViewModel: ObservableObject {
    @Published var animeData: [AnimeNode] = []
    @Published var filterResults: [AnimeNode] = []  // maybe use .filter{ }
    @Published var filterText = ""
    @Published var selectedViewMode: ViewMode = .watching
    @Published var selectedSearchMode: SearchMode = .all
    
    static let TAG = "[HomeViewModel]" // for debugging
    
    func addAnime(anime: Anime) async {
        // 1. Create record object
        let record = CKRecord(recordType: "Anime")
        
        // 2. Set values of record
        record.setValuesForKeys([
            "id": anime.id,
            "episodes_seen": 0,
//            "status": "watching"
        ])
        
        // 3. Save record to cloudkit
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
            
        do {
            try await database.save(record)
            // Record saved sucessfully.
            print("\(HomeViewModel.TAG) Record saved successfully.")
            
        } catch {
            // Handle error.
            print("\(HomeViewModel.TAG) Error saving record: \(error)")
        }
        
    }
    
    // Fetches anime data for user from CloudKit.
    func fetchAnimes() async {
        let container = CKContainer.default()
        let database = container.publicCloudDatabase

        do {
            // Fetch animes of current user
            let userID = try await container.userRecordID()
            let recordToMatch = CKRecord.Reference(recordID: userID, action: .none)
            // different name from cloudkit dashboard for some reason... Also need to add index to make it queryable
            let predicate = NSPredicate(format: "creatorUserRecordID == %@", recordToMatch)
            let query = CKQuery(recordType: "Anime", predicate: predicate)
//            let queryOp = CKQueryOperation(query: query)
            
            let (animeResults, cursor) = try await database.records(matching: query)
            
            var animeNodes: [AnimeNode] = []
            for (recordID, result) in animeResults { // result is (CKRecord, error)
                switch result {
                case .success(let record):
                    if let id = record["id"] as? Int {
                        // MAL api call to get anime data
                        var animeNode = try await fetchAnimeByID(id: id)
                        animeNode.record = record
                        animeNodes.append(animeNode)
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
            
            // update user's list with new data
            self.animeData = animeNodes
            
        } catch let operationError {
            // Handle error.
            print("\(HomeViewModel.TAG) Error fetching anime ids: \(operationError)")
            return
        }
    }
    
    let baseUrl = "https://api.myanimelist.net/v2"
    let apiKey = "e7bc56aa1b0ea0afe3299d889922e5b8"
    
    func fetchAnimeByID(id: Int) async throws -> AnimeNode {
        let fieldValue = MyAnimeListApi.fieldValues.joined(separator: ",")
        guard let url = URL(string: "\(baseUrl)/anime/\(id)?fields=\(fieldValue)") else { throw FetchError.badRequest }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        
        // get anime data from rest api
        let anime = try JSONDecoder().decode(Anime.self, from: data)
        
        return AnimeNode(node: anime)
    }
    
    // Only OP can delete post, no one else can.
    func deleteAnime(recordToDelete: CKRecord) async {
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        do {
            print(recordToDelete.recordID.recordName)
            try await database.deleteRecord(withID: recordToDelete.recordID)
            // delete post locally aswell (better than re-fetching data to update ui)
            self.animeData = self.animeData.filter {$0.record.recordID != recordToDelete.recordID}
            print("\(HomeViewModel.TAG) Successfully deleted anime.")
        } catch {
            print("\(HomeViewModel.TAG) Error deleting post: \(error)")
        }
    }
}
