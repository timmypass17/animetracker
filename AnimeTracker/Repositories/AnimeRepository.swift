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
    @Published var searchResults: [AnimeNode] = []
    private lazy var container: CKContainer = CKContainer.default()
    private lazy var database: CKDatabase = container.publicCloudDatabase
    private let limit = 10
    private let TAG = "[AnimeRepository]"
    
    init() {
        Task {
            await fetchAnimesFromCloudKit()
        }
    }
    
    func fetchAnime(animeID: Int) async throws -> AnimeNode {
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime/\(animeID)?fields=\(MyAnimeListApi.fieldValues)") else { throw FetchError.badURL }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest } // 200 indicates successful request
        
        var anime = try JSONDecoder().decode(Anime.self, from: data)
//        anime.animeType = .anime
        return AnimeNode(node: anime)
    }
    
    func fetchAnimes(title: String) async throws {
        guard title != "" else {
            searchResults = []
            return
        }
        
        // Create query url
        let titleFormatted = title.replacingOccurrences(of: " ", with: "_")
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime?q=\(titleFormatted)&fields=\(MyAnimeListApi.fieldValues)&limit=\(limit)") else { return }
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
//            searchResults[index].node.animeType = .anime
            for item in animeData {
                if item.node.id == animeNode.node.id {
                    searchResults[index].record = item.record
                }
            }
        }
    }
    
    func fetchMangasByTitle(title: String, limit: Int = 15) async throws {
        print(title)
        guard title != "" else {
            searchResults = []
            return
        }
        
        // Create query url
        let titleFormatted = title.replacingOccurrences(of: " ", with: "_")
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/manga?q=\(titleFormatted)&fields=\(MyAnimeListApi.fieldValues)&limit=\(limit)") else { return }
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
//            // set corresponding type (
//            switch animeNode.node.media_type {
//            case "manga":
//                searchResults[index].node.animeType = .manga
//            case "light_novel":
//                searchResults[index].node.animeType = .novels
//            case "manhwa":
//                searchResults[index].node.animeType = .manhwa
//            case "manhua":
//                searchResults[index].node.animeType = .manhua
//            case "one_shot":
//                searchResults[index].node.animeType = .oneshots
//            case "doujinshi":
//                searchResults[index].node.animeType = .doujin
//            default:
//                searchResults[index].node.animeType = .anime
//            }
//            searchResults[index].node.animeType = MediaType(rawValue: animeNode.node.media_type!.rawValue)
            
            for item in animeData {
                if item.node.id == animeNode.node.id {
                    searchResults[index].record = item.record
                }
            }
        }
    }
    
    func fetchMangaByID(mangaID: Int) async throws -> AnimeNode {
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/manga/\(mangaID)?fields=\(MyAnimeListApi.fieldValues)") else { throw FetchError.badRequest }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        
        // get anime data from rest api
        var manga = try JSONDecoder().decode(Anime.self, from: data)
//        manga.animeType = animeType
        return AnimeNode(node: manga)
    }
    
    
    func saveAnime(animeNode: AnimeNode) async {        
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
                "episodes_seen": animeNode.episodes_seen,
                "type": animeNode.node.animeType.rawValue
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
                    if let id = record["id"] as? Int, let type = AnimeType(rawValue: record["type"] as? String ?? "anime") {
                        if type == .anime {
                            // MAL api call to get anime data
                            var animeNode = try await fetchAnime(animeID: id)
                            animeNode.record = record   // save record into anime object
                            animeNodes.append(animeNode)
                        } else {
                            var mangaNode = try await fetchMangaByID(mangaID: id)
                            mangaNode.record = record
                            animeNodes.append(mangaNode)
                        }
                    }
                    
                case .failure(let error):
                    print("Failed to fetch anime from cloudkit: \(error)")
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
    
}

extension AnimeRepository {
    
    func fetchAnimesBySeason(season: Season, year: Int, page: Int) async throws -> AnimeCollection {
        let offset = page * limit
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime/season/\(year)/\(season.rawValue)?&fields=\(MyAnimeListApi.fieldValues)&limit=\(limit)&offset=\(offset)&sort=anime_num_list_users") else { throw FetchError.badRequest }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        
        do {
            var animeCollection = try JSONDecoder().decode(AnimeCollection.self, from: data)
//            animeCollection.data.indices.forEach { animeCollection.data[$0].node.animeType = .anime } // add aditional field
            return animeCollection
        } catch {
            print(error)
        }
        
        return AnimeCollection()
    }
    
    func fetchMangasByType(animeType: AnimeType, page: Int) async throws -> AnimeCollection {
        print(TAG, animeType)
        let offset = page * limit
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/manga/ranking?ranking_type=\(animeType.rawValue)&fields=\(MyAnimeListApi.fieldValues)&limit=\(limit)&offset=\(offset)") else { throw FetchError.badRequest }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        
        do {
            var mangaData = try JSONDecoder().decode(AnimeCollection.self, from: data)
//            mangaData.data.indices.forEach { mangaData.data[$0].node.animeType = animeType }
            return mangaData
        } catch {
            print(error)
        }
        return AnimeCollection()
    }
    
}

