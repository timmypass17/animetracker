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

enum FetchError: Error {
    case badRequest
    case badJson
}

@MainActor // to automatically dispatch UI updates on the main queue. Same as doing DispatchQueue.main.async{}
class HomeViewModel: ObservableObject {
    @Published var animeData: [AnimeNode] = []
    @Published var filterResults: [AnimeNode] = []  // maybe use .filter{ }
    @Published var filterText = ""
    @Published var selectedViewMode: ViewMode = .watching
    @Published var selectedSearchMode: SearchMode = .all
    
    @Published var searchResults: [AnimeNode] = []
    @Published var searchText = ""
    
    let TAG = "[HomeViewModel]" // for debugging
    let baseUrl = "https://api.myanimelist.net/v2"
    let apiKey = "e7bc56aa1b0ea0afe3299d889922e5b8"

    init() {
        print("\(TAG) Initializing HomeViewModel")
        Task {
            // request api call only once. Every "addition" is done locally, abstracted from user
            await self.fetchAnimes()
        }
    }
    
    // Add anime to CloudKit.
    func addAnime(anime: Anime, episodes_seen: Int, isBookedmarked: Bool) async {
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        
        // modifiy existing record
        if let index = self.animeData.firstIndex(where: { $0.node.id == anime.id } ) {
            var record = self.animeData[index].record
            record["episodes_seen"] = episodes_seen
            record["bookmarked"] = isBookedmarked
            
            // I have to replace the array item entirely to be picked up by SwiftUI? Modifying the record itself doesn't do the automatic update..
            self.animeData[index] = AnimeNode(node: anime, record: record)
            do {
                try await database.save(record) // slow, takes a few seconds for record to be saved onto cloudkit? skill diff
                // Record saved sucessfully.
                print("\(TAG) Updated \(anime.title) successfully.")
            } catch {
                // Handle error.
                print("\(TAG) Error saving record: \(error)")
            }
            return
        }
        
        // create new record
        // 1. Create record object
        let record = CKRecord(recordType: "Anime")
        
        // 2. Set values of record
        record.setValuesForKeys([
            "id": anime.id,
            "episodes_seen": episodes_seen,
            "bookmarked": isBookedmarked
        ])
        
        // add locally, set values
        var tempAnime = AnimeNode(node: anime)
        tempAnime.record = record
        self.animeData.append(tempAnime)
        
        // 3. Save record to cloudkit
        do {
            try await database.save(record) // slow, takes a few seconds for record to be saved onto cloudkit? skill diff
            // Record saved sucessfully.
            print("\(TAG) Added \(anime.title) successfully.")
        } catch {
            // Handle error.
            print("\(TAG) Error saving record: \(error)")
        }
    }
    
    // Fetches user's anime list from CloudKit
    func fetchAnimes() async {
        print("\(TAG) fetchAnimes()")
        
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
                        animeNode.record = record   // save record into anime object
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
            print("\(TAG) Error fetching anime ids: \(operationError)")
            return
        }
    }

    // Fetch anime from MAL API
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
    
    // Fetch anime by title from MAL API
    func fetchAnimeByTitle(title: String) async throws {
        guard title != "" else {
            return
        }
        
        print("[SearchViewModel] fetchAnime(\"\(title)\")")
        let titleFormatted = title.replacingOccurrences(of: " ", with: "_")
        
        let fieldValue = MyAnimeListApi.fieldValues.joined(separator: ",")
        guard let url = URL(string: "\(baseUrl)/anime?q=\(titleFormatted)&fields=\(fieldValue)") else { return }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        
        Task { @MainActor in
            self.searchResults = []
            do {
                self.searchResults = try JSONDecoder().decode(AnimeCollection.self, from: data).data
                
                // get episodes seen from user's local list
                for item in searchResults {
                    for animeNode in self.animeData {
                        if animeNode.node.id == item.node.id {
                            if let episodes_seen = animeNode.record["episodes_seen"] as? Int {
                                item.record.setValue(episodes_seen, forKey: "episodes_seen")
                            }
                            break
                        }
                        
                    }
                }
            } catch {
                print(error)
            }
        }
    }

    //
    
    // Delete anime record from CloudKit
    func deleteAnime(recordToDelete: CKRecord) async {
        // Note: only OP can delete post, no one else can.
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        do {
            print(recordToDelete.recordID.recordName)
            try await database.deleteRecord(withID: recordToDelete.recordID)
            // delete post locally aswell (better than re-fetching data to update ui)
            self.animeData = self.animeData.filter {$0.record.recordID != recordToDelete.recordID}
            print("\(TAG) Successfully deleted anime.")
        } catch {
            print("\(TAG) Error deleting post: \(error)")
        }
    }
}
