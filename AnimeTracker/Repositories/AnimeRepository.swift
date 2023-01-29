//
//  AnimeRepository.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/28/23.
//

import Foundation
import CloudKit

@MainActor
class AnimeRepository: ObservableObject, MyAnimeListApiService, CloudKitService {
    @Published var animeData: [AnimeNode] = []
    @Published var fallData: [AnimeNode] = []
    @Published var summerData: [AnimeNode] = []
    @Published var springData: [AnimeNode] = []
    @Published var winterData: [AnimeNode] = []
    @Published var searchResults: [AnimeNode] = []

    let container: CKContainer = CKContainer.default()
    var database: CKDatabase {
        container.publicCloudDatabase
    }
    let TAG = "[AnimeRepository]"

    init() {
        Task {
            await fetchAnimesFromCloudKit()
            fallData = try await fetchAnimeBySeason(season: .fall, year: getCurrentYear() - 1, limit: 15)
            summerData = try await fetchAnimeBySeason(season: .summer, year: getCurrentYear() - 1, limit: 15)
            springData = try await fetchAnimeBySeason(season: .spring, year: getCurrentYear() - 1, limit: 15)
            winterData = try await fetchAnimeBySeason(season: .winter, year: getCurrentYear() - 1, limit: 15)
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
    
    func fetchAnimeByRank(rankingType: Ranking) async throws -> [AnimeNode] {
        let fieldValue = MyAnimeListApi.fieldValues.joined(separator: ",")
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime/ranking?ranking_type=\(rankingType.rawValue)&fields=\(fieldValue)") else { throw FetchError.badRequest }
                
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        
        // get anime data from rest api
        let animes = try JSONDecoder().decode(AnimeCollection.self, from: data).data
        return animes
    }
    
    func fetchAnimeBySeason(season: Season, year: Int, limit: Int = 100) async throws -> [AnimeNode] {
        let fieldValue = MyAnimeListApi.fieldValues.joined(separator: ",")
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime/season/\(year)/\(season.rawValue)?sort=&anime_score&fields=\(fieldValue)&limit=\(limit)") else { throw FetchError.badRequest }

        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        
        // get anime data from rest api
        let animes = try JSONDecoder().decode(AnimeCollection.self, from: data).data
        return animes.sorted(by: { $0.node.mean ?? 0.0 > $1.node.mean ?? 0.0 })
    }

    
    func addAnime(animeNode: AnimeNode) async {
        // local updates
        if let index = searchResults.firstIndex(where: { $0.node.id == animeNode.node.id }) {
            searchResults[index] = animeNode
        }
        
        var record: CKRecord
        if let index = animeData.firstIndex(where: { $0.node.id == animeNode.node.id }) {
            // 1. Update existing record
            animeData[index] = AnimeNode(node: animeNode.node, record: animeNode.record)
            record = animeData[index].record
        } else {
            // 2. Add new record
            animeData.append(animeNode)
            record = animeNode.record
            
            record.setValuesForKeys([
                "id": animeNode.node.id,
                "episodes_seen": animeNode.episodes_seen
            ])
        }
        
        await saveItem(record: record)
    }
    
    // Fetches user's anime list from CloudKit
    func fetchAnimesFromCloudKit() async {
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
            self.animeData = animeNodes.sorted { $0.record.modificationDate! > $1.record.modificationDate! } // sort by last modified, use user defaults
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
    
    
    private func saveItem(record: CKRecord) async {
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
    
    private func getCurrentYear() -> Int {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: date)
        return Int(yearString)!
    }
    
}
