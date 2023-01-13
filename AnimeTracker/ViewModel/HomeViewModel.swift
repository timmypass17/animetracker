//
//  HomeViewModel.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import Foundation
import CloudKit


@MainActor // to automatically dispatch UI updates on the main queue. Same as doing DispatchQueue.main.async{}
class HomeViewModel: ObservableObject {
    @Published var animeData: [AnimeNode] = [] // underying data
    @Published var filterResults: [AnimeNode] = []
    @Published var selectedViewMode: ViewMode = .all
    @Published var searchResults: [AnimeNode] = []
    @Published var selectedSearchMode: SearchMode = .all
    @Published var filterText = ""

    @Published var searchText = ""
    
    @Published var selectedAnimeData: [AnimeNode] = []
    var selectedData: [AnimeNode] {
        switch selectedViewMode {
        case .all:
            return animeData
        case .watching:
            // Get animes between range 0 to num_episodes - 1
            return animeData.filter { 0 ... $0.node.num_episodes - 1 ~= ($0.record["episodes_seen"] as? Int ?? 0) }
        case .completed:
            return animeData.filter { ($0.record["episodes_seen"] as? Int ?? 0) == $0.node.num_episodes}
        case .planning:
            return animeData.filter { $0.record["bookmarked"] as? Bool ?? false }
        }
    }

    let TAG = "[HomeViewModel]" // for debugging

    init() {
        Task {
            // request api call only once. Every "addition" is done locally, abstracted from user
            await fetchAnimes()
            selectedAnimeData = animeData
        }
    }
    
    func addAnime(animeNode: AnimeNode) async {
        // local updates
        if let index = searchResults.firstIndex(where: { $0.node.id == animeNode.node.id }) {
            searchResults[index] = animeNode
        }
        
        var record: CKRecord
        if let index = animeData.firstIndex(where: { $0.node.id == animeNode.node.id }) {
            // 1. Update existing record
            print("addAnime existing")
            animeData[index] = AnimeNode(node: animeNode.node, record: animeNode.record)
            record = animeData[index].record
        } else {
            // 2. Add new record
            print("addAnime new")
            animeData.append(animeNode)
            record = animeNode.record
            
            record.setValuesForKeys([
                "id": animeNode.node.id,
                "episodes_seen": animeNode.episodes_seen,
                "bookmarked": animeNode.bookmarked
            ])
        }
        
        await saveItem(record: record)
    }
    
    func saveItem(record: CKRecord) async {
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        do {
            try await database.save(record) // slow, takes a few seconds for record to be saved onto cloudkit? skill diff
            // Record saved sucessfully.
            print("\(TAG) Added record successfully.")
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
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime/\(id)?fields=\(fieldValue)") else { throw FetchError.badRequest }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        
        // get anime data from rest api
        let anime = try JSONDecoder().decode(Anime.self, from: data)
        return AnimeNode(node: anime)
    }

//    // Fetch anime from MAL API
//    func fetchAnimeByID(id: Int) async throws -> AnimeNode {
//        let fieldValue = MyAnimeListApi.fieldValues.joined(separator: ",")
//        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime/\(id)?fields=\(fieldValue)") else { throw FetchError.badRequest }
//
//        var request = URLRequest(url: url)
//        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
//            throw FetchError.badRequest
//        }
//
//        // get anime data from rest api
//        let anime = try JSONDecoder().decode(Anime.self, from: data)
//        return AnimeNode(node: anime)
//    }
    
    // Fetch anime by title from MAL API
    func fetchAnimesByTitle(title: String) async throws {
        guard title != "" else { return }
        
        // Create query url
        let titleFormatted = title.replacingOccurrences(of: " ", with: "_")
        let fieldValue = MyAnimeListApi.fieldValues.joined(separator: ",")
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime?q=\(titleFormatted)&fields=\(fieldValue)") else { return }
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        // Send network request to get anime data
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
        
        do {
            // Store result into viewmodel
            searchResults = try JSONDecoder().decode(AnimeCollection.self, from: data).data
        } catch {
            print(error)
        }
        
        // Update record for each search item using existing record in animeData!
        for (index, animeNode) in searchResults.enumerated() {
            for item in animeData {
                if item.node.id == animeNode.node.id {
                    searchResults[index].record = item.record
                }
            }
        }
    }
    
    // Delete anime record from CloudKit. Note: only OP can delete post, no one else can.
    func deleteAnime(animeNode: AnimeNode) async {
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        
        if let index = animeData.firstIndex(where: { $0.node.id == animeNode.node.id }) {
            animeData.remove(at: index)
        }
        
        do {
            let recordToDelete = animeNode.record
            try await database.deleteRecord(withID: recordToDelete.recordID)
            // delete post locally aswell (better than re-fetching data to update ui)
            self.animeData = self.animeData.filter {$0.record.recordID != recordToDelete.recordID}
            print("\(TAG) Successfully deleted anime.")
        } catch {
            print("\(TAG) Error deleting post: \(error)")
        }
    }
    
    func filterDataByTitle(query: String) {
        filterResults = animeData.filter { $0.node.title.lowercased().contains(query.lowercased()) }
    }
}

enum ViewMode: String, CaseIterable, Identifiable {
    case all, watching, completed, planning
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
