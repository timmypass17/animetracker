//
//  AnimeViewModel.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import Foundation
import CloudKit


@MainActor // to automatically dispatch UI updates on the main queue. Same as doing DispatchQueue.main.async{}
class AnimeViewModel: ObservableObject {
    @Published var animeData: [AnimeNode] = [] // underying data
    @Published var selectedAnimeData: [AnimeNode] = []
    @Published var filterResults: [AnimeNode] = []
    @Published var searchResults: [AnimeNode] = []
    @Published var selectedViewMode: ViewMode = .all
    @Published var selectedSearchMode: SearchMode = .all
    @Published var selectedSort: SortBy = .last_modified
    @Published var filterText = ""
    @Published var searchText = ""
    
    let TAG = "[AnimeViewModel]" // for debugging
    
    
    init() {
        Task {
            // request api call only once. Every "addition" is done locally, abstracted from user
            await fetchAnimes()
            applySort()
        }
    }
    
    func applySort() {
        sortByMode()
        sortBySorting()
    }
    
    private func sortByMode() {
        switch selectedViewMode {
        case .all:
            selectedAnimeData = animeData
        case .in_progress:
            // Get animes between range 1 to num_episodes - 1
            selectedAnimeData = animeData.filter { 1 ... $0.node.num_episodes - 1 ~= ($0.record["episodes_seen"] as? Int ?? 0) }
        case .finished:
            selectedAnimeData = animeData.filter { ($0.record["episodes_seen"] as? Int ?? 0) == $0.node.num_episodes}
        case .not_started:
            selectedAnimeData = animeData.filter { $0.record["episodes_seen"] as? Int == 0 }
        }
    }
    
    private func sortBySorting() {
        switch selectedSort {
        case .alphabetical:
            selectedAnimeData = selectedAnimeData.sorted { $0.node.title < $1.node.title }
        case .newest:
            selectedAnimeData = selectedAnimeData.sorted { $0.node.start_season?.year ?? 9999 > $1.node.start_season?.year ?? 9999 }
        case .date_created:
            selectedAnimeData = selectedAnimeData.sorted { $0.record.creationDate! > $1.record.creationDate! } // most recent on top
        case .last_modified:
            selectedAnimeData = selectedAnimeData.sorted { $0.record.modificationDate! > $1.record.modificationDate! }
        }
    }
    
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
    
    func fetchAnimesByTitle(title: String, limit: Int = 15) async throws {
        guard title != "" else {
            searchResults = []
            return
        }
        
        // Create query url
        let titleFormatted = title.replacingOccurrences(of: " ", with: "_")
        let fieldValue = MyAnimeListApi.fieldValues.joined(separator: ",")
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime?q=\(titleFormatted)&fields=\(fieldValue)&limit=\(limit)") else { return }
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
//                "bookmarked": animeNode.bookmarked
            ])
        }
        
        await saveItem(record: record)
    }

    // Fetches user's anime list from CloudKit
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
    
    func filterDataByTitle(query: String) {
        filterResults = animeData.filter { $0.node.title.lowercased().contains(query.lowercased()) }
    }
}

enum ViewMode: String, CaseIterable, Identifiable {
    case all, not_started, in_progress, finished
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

enum Tab {
    case list
    case search
    case chart
}

enum SortBy: String, CaseIterable, Identifiable {
    case alphabetical
    case newest
    case date_created = "Date Created"
    case last_modified = "Last Modified"
    var id: Self { self }
}
