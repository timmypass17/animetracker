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
            animeData = await fetchAnimesFromCloudKit()
        }
    }
    
    /// Retrieves specific anime from MyAnimeList database using anime's id.
    /// - Parameters:
    ///     - animeID: Anime's unique identifier.
    /// - Returns: Anime from MyAnimeList with that id.
    func fetchAnime(animeID: Int) async throws -> AnimeNode {
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime/\(animeID)?fields=\(MyAnimeListApi.fieldValues)") else { throw FetchError.badURL }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest } // 200 indicates successful request
        
        do {
            let anime = try JSONDecoder().decode(Anime.self, from: data)
            return AnimeNode(node: anime)
        } catch {
            print("\(TAG) Error calling fetchAnime(animeID: \(animeID)) \n \(error)")
        }
        
        return AnimeNode(node: Anime(id: 0))
    }
    
    /// Retrieves animes from MyAnimeList matchinig title query.
    /// - Parameters:
    ///     - title: Name of anime.
    /// - Returns: List of animes from MyAnimeList relating to title query.
    func fetchAnimes(title: String) async throws -> AnimeCollection {
        guard !title.isEmpty else { return AnimeCollection() }
        
        let titleFormatted = title.replacingOccurrences(of: " ", with: "_")
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime?q=\(titleFormatted)&fields=\(MyAnimeListApi.fieldValues)&limit=\(limit)") else { return AnimeCollection() }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
        
        do {
            var animeCollection = try JSONDecoder().decode(AnimeCollection.self, from: data)
            
            // Update record for each search item using user's list.
            for (index, searchItem) in animeCollection.data.enumerated() {
                if let existingAnime = animeData.first(where: { searchItem.node.id == $0.node.id}) {
                    animeCollection.data[index].record = existingAnime.record
                }
            }
            
            return animeCollection
        } catch {
            print("\(TAG) Error calling fetchAnimes(title: \(title)) \n \(error)")
        }
        
        return AnimeCollection()
    }
    
    /// Retrieves animes from MyAnimeList from that season and year.
    /// - Parameters:
    ///     - season: Starting season of anime.
    ///     - year: Starting year of anime.
    ///     - page: For paging
    /// - Returns: List of animes from MyAnimeList from that season and year.
    func fetchAnimes(season: Season, year: Int, page: Int) async throws -> AnimeCollection {
        let offset = page * limit
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime/season/\(year)/\(season.rawValue)?&fields=\(MyAnimeListApi.fieldValues)&limit=\(limit)&offset=\(offset)&sort=anime_num_list_users") else { throw FetchError.badRequest }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
        
        do {
            let animeCollection = try JSONDecoder().decode(AnimeCollection.self, from: data)
            return animeCollection
        } catch {
            print("\(TAG) Error calling fetchAnimes(season: \(season), year: \(year), page: \(page)) \n \(error)")
        }
        
        return AnimeCollection()
    }
    
    /// Retrieves mangas from MyAnimeList using manga's id.
    /// - Parameters:
    ///     - mangaID: Manga's unique identifier
    /// - Returns: List of mangas from MyAnimeList using that id.
    func fetchManga(mangaID: Int) async throws -> AnimeNode {
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/manga/\(mangaID)?fields=\(MyAnimeListApi.fieldValues)") else { throw FetchError.badRequest }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        
        do {
            let manga = try JSONDecoder().decode(Anime.self, from: data)
            return AnimeNode(node: manga)
        } catch {
            print("\(TAG) Error calling fetchManga(mangaID: \(mangaID)) \n \(error)")
        }
        
        return AnimeNode(node: Anime(id: 0))
    }
    
    /// Retrieves mangas from MyAnimeList matching title query.
    /// - Parameters:
    ///     - title: Name of manga
    /// - Returns: List of mangas from MyAnimeList relating to title query.
    func fetchMangas(title: String) async throws -> AnimeCollection {
        guard !title.isEmpty else {
            return AnimeCollection()
        }
        
        let titleFormatted = title.replacingOccurrences(of: " ", with: "_")
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/manga?q=\(titleFormatted)&fields=\(MyAnimeListApi.fieldValues)&limit=\(limit)") else { return AnimeCollection() }
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
        
        do {
            var mangaCollection = try JSONDecoder().decode(AnimeCollection.self, from: data)
            
            // Update record for each search item using user's list.
            for (index, searchItem) in mangaCollection.data.enumerated() {
                if let existingAnime = animeData.first(where: { searchItem.node.id == $0.node.id}) {
                    mangaCollection.data[index].record = existingAnime.record
                }
            }
            
            return mangaCollection
            
        } catch {
            print("\(TAG) Error calling fetchMangas(title: \(title)) \n \(error)")
        }
        
        return AnimeCollection()
    }
    
    /// Retrieves mangas from MyAnimeList using anime's type.
    /// - Parameters:
    ///     - animeType: Type of media. (ex. anime, manga, novels)
    ///     - page: For paging
    /// - Returns: List of mangas from MyAnimeList using that id.
    func fetchMangas(animeType: AnimeType, page: Int) async throws -> AnimeCollection {
        let offset = page * limit
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/manga/ranking?ranking_type=\(animeType.rawValue)&fields=\(MyAnimeListApi.fieldValues)&limit=\(limit)&offset=\(offset)") else { throw FetchError.badRequest }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        
        do {
            let mangaData = try JSONDecoder().decode(AnimeCollection.self, from: data)
            return mangaData
        } catch {
            print("\(TAG) Error calling fetchMangas(animeType: \(animeType), page: \(page)) \n \(error)")
        }
        
        return AnimeCollection()
    }
    
    /// Saves anime to public database as Anime records.
    /// - Parameters:
    ///     - animeNode: Anime that we using to extract relevant info
    /// - Returns: List of mangas from MyAnimeList using that id.
    func saveAnime(animeNode: AnimeNode) async {
        if let index = searchResults.firstIndex(where: { $0.node.id == animeNode.node.id }) {
            searchResults[index] = animeNode
        }
        
        // Update existing record
        if let index = animeData.firstIndex(where: { $0.node.id == animeNode.node.id }) {
            animeData[index] = animeNode
            
            do {
                let record = animeData[index].record
                try await database.save(record)
                print("\(TAG) Added record successfully.")
                
            } catch {
                print("\(TAG) Error saving record: \(error)")
            }
        }
        else {
            // Create new record
            animeData.append(animeNode)
            let record = animeNode.record
            record.setValuesForKeys([
                Anime.RecordKey.animeID.rawValue: animeNode.node.id,
                Anime.RecordKey.seen.rawValue: animeNode.record[.seen] as? Int ?? 0,
                Anime.RecordKey.animeType.rawValue: animeNode.node.animeType.rawValue
            ])
            
            do {
                try await database.save(record)
                print("\(TAG) Added record successfully.")
            } catch {
                print("\(TAG) Error saving record: \(error)")
            }
        }
    }
    
    /// Retrieves animes from MyAnimeList using user's Anime records from public databse.
    /// - Returns: List of animes from MyAnimeList.
    func fetchAnimesFromCloudKit() async -> [AnimeNode] {
        var animeNodes: [AnimeNode] = []

        do {
            let userID = try await container.userRecordID()
            let recordToMatch = CKRecord.Reference(recordID: userID, action: .none)
            // different name from cloudkit dashboard for some reason. Also need to add index to make it queryable
            let predicate = NSPredicate(format: "creatorUserRecordID == %@", recordToMatch)
            let query = CKQuery(recordType: "Anime", predicate: predicate)
            
            let (animeResults, cursor) = try await database.records(matching: query)

            for (recordID, result) in animeResults {
                switch result {
                case .success(let record):
                    guard let id = record[.animeID] as? Int else { continue }
                    guard let animeType = AnimeType(rawValue: record[.animeType] as? String ?? "anime") else { continue }
                    
                    var animeNode: AnimeNode
                    if animeType == .anime {
                        print("anime")
                        animeNode = try await fetchAnime(animeID: id)
                        print("a")
                    } else {
                        print(animeType.rawValue)
                        animeNode = try await fetchManga(mangaID: id)
                    }
                    animeNode.record = record
                    animeNodes.append(animeNode)
                    
                case .failure(let error):
                    print("\(TAG) Failed to fetch anime from cloudkit: \(error)")
                }
            }
            
            return animeNodes.sorted { $0.record.modificationDate! > $1.record.modificationDate! }
            
        } catch {
            print("\(TAG) Error calling fetchAnimesFromCloudKit(): \(error)")
            return []
        }
    }
    
    /// Delete an Anime record.
    /// - Parameters:
    ///     - animeNode: Anime object containing record to delete from CloudKit.
    func deleteAnime(animeNode: AnimeNode) async {
        do {
            let recordToDelete = animeNode.record
            animeData = animeData.filter { $0.record.recordID != recordToDelete.recordID }
            try await database.deleteRecord(withID: recordToDelete.recordID)
            print("\(TAG) Successfully removed \(String(describing: animeNode.node.title)).")
        } catch {
            print("\(TAG) Failed to remove \(String(describing: animeNode.node.title)) \n \(error)")
        }
    }
    
}

enum FetchError: Error {
    case badRequest
    case badJson
    case badURL
}
