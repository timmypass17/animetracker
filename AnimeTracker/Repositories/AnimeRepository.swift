//
//  AnimeRepository.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/28/23.
//

import Foundation
import CloudKit


@MainActor
class AnimeRepository: ObservableObject /**MyAnimeListApiService, CloudKitService **/ {
    @Published var animeData: [WeebItem]
    @Published var searchResults: [WeebItem] // might remove?
    private lazy var container: CKContainer = CKContainer.default()
    private lazy var database: CKDatabase = container.privateCloudDatabase
    private let limit = 10
    private let TAG = "[AnimeRepository]"
    private var userID: CKRecord.ID?
    
    init(animeData: [WeebItem] = [], searchResults: [WeebItem] = []) { // init for sample data
        self.animeData = animeData
        self.searchResults = searchResults
        
        Task {
            userID = try await container.userRecordID()
            loadUserAnimeList()
        }
    }
    
    /// Retrieves specific anime from MyAnimeList database using anime's id.
    /// - Parameters:
    ///     - animeID: Anime's unique identifier.
    /// - Returns: Anime from MyAnimeList with that id.
    func fetchAnime(animeID: Int) async -> Result<Anime, Error> {
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime/\(animeID)?fields=\(MyAnimeListApi.animeField)")
        else { return .failure(FetchError.badURL) }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return .failure(FetchError.badRequest) }
            
            let anime = try JSONDecoder().decode(Anime.self, from: data)
            return .success(anime)
        } catch {
            print("\(TAG) Error calling fetchAnime(animeID: \(animeID)) \n \(error)")
            return .failure(error)
        }
    }
    
    /// Retrieves animes from MyAnimeList matchinig title query.
    /// - Parameters:
    ///     - title: Name of anime.
    /// - Returns: List of animes from MyAnimeList relating to title query.
    func fetchAnimes(title: String) async -> Result<AnimeCollection<Anime>, Error> {
        guard !title.isEmpty else { return .failure(FetchError.badURL) }
        
        let titleFormatted = title.replacingOccurrences(of: " ", with: "_")
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime?q=\(titleFormatted)&fields=\(MyAnimeListApi.animeField)&limit=\(limit)")
        else { return .failure(FetchError.badURL) }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return .failure(FetchError.badRequest) }
            
            var animeCollection = try JSONDecoder().decode(AnimeCollection<Anime>.self, from: data)
            print("Successfully got anime")
            // Update record for each search item using user's list.
//            for (index, searchItem) in animeCollection.data.enumerated() {
//                if let existingAnime = animeData.first(where: { searchItem.node.id == $0.node.id}) {
//                    animeCollection.data[index].record = existingAnime.record
//                }
//            }
            return .success(animeCollection)
            
        } catch {
            print("\(TAG) Error calling fetchAnimes(title: \(title)) \n \(error)")
            return .failure(error)
        }
    }
    
    
    func fetchTopAiringAnimes(page: Int = 0) async -> Result<AnimeCollection<Anime>, Error> {
        do {
            let offset = page * limit
            guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime/ranking?ranking_type=airing&fields=\(MyAnimeListApi.animeField)&limit=\(limit)&offset=\(offset)") else { throw FetchError.badURL }
            
            var request = URLRequest(url: url)
            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest } // 200 indicates successful request
            
            let animeCollection = try JSONDecoder().decode(AnimeCollection<Anime>.self, from: data)
            return .success(animeCollection)
        } catch {
            print("\(TAG) Error fetching top airing animes: \(error)")
            return .failure(error)
        }
    }
    
    func fetchPopularMangas(page: Int = 0) async -> Result<AnimeCollection<Manga>, Error> {
        do {
            let offset = page * limit
            guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/manga/ranking?ranking_type=bypopularity&fields=\(MyAnimeListApi.mangaField)&limit=10&offset=\(offset)") else { throw FetchError.badURL }
            
            var request = URLRequest(url: url)
            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest } // 200 indicates successful request
            
            let animeCollection = try JSONDecoder().decode(AnimeCollection<Manga>.self, from: data)
            return .success(animeCollection)
        } catch {
            print("\(TAG) Error fetching popular mangas: \(error)")
            return .failure(error)
        }
    }
    
    /// Retrieves animes from MyAnimeList from that season and year.
    /// - Parameters:
    ///     - season: Starting season of anime.
    ///     - year: Starting year of anime.
    ///     - page: For paging
    /// - Returns: List of animes from MyAnimeList from that season and year.
    func fetchAnimes(season: Season, year: Int, page: Int) async -> Result<AnimeCollection<Anime>, Error> {
        do {
            let offset = page * limit

            guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime/season/\(year)/\(season.rawValue)?&fields=\(MyAnimeListApi.animeField)&limit=\(limit)&offset=\(offset)&sort=anime_num_list_users") else { throw FetchError.badRequest }
            
            var request = URLRequest(url: url)
            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
        
            let animeCollection = try JSONDecoder().decode(AnimeCollection<Anime>.self, from: data)
            return .success(animeCollection)
        } catch {
            print("\(TAG) Error calling fetchAnimes(season: \(season), year: \(year), page: \(page)) \n \(error)")
            return .failure(error)
        }
    }
    
    /// Retrieves mangas from MyAnimeList using manga's id.
    /// - Parameters:
    ///     - mangaID: Manga's unique identifier
    /// - Returns: List of mangas from MyAnimeList using that id.
    func fetchManga(mangaID: Int) async -> Result<Manga, Error> {
        do {
            guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/manga/\(mangaID)?fields=\(MyAnimeListApi.mangaField)") else { throw FetchError.badRequest }
            
            var request = URLRequest(url: url)
            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw FetchError.badRequest
            }
            let manga = try JSONDecoder().decode(Manga.self, from: data)
            return .success(manga)
        } catch {
            print("\(TAG) Error calling fetchManga(mangaID: \(mangaID)) \n \(error)")
            return .failure(error)
        }
    }
    
    /// Retrieves mangas from MyAnimeList matching title query.
    /// - Parameters:
    ///     - title: Name of manga
    /// - Returns: List of mangas from MyAnimeList relating to title query.
    func fetchMangas(title: String) async -> Result<AnimeCollection<Manga>, Error> {
        do {
            guard !title.isEmpty else { throw FetchError.badRequest }
            
            let titleFormatted = title.replacingOccurrences(of: " ", with: "_")
            guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/manga?q=\(titleFormatted)&fields=\(MyAnimeListApi.animeField)&limit=\(limit)") else { throw FetchError.badURL }
            var request = URLRequest(url: url)
            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
            var mangaCollection = try JSONDecoder().decode(AnimeCollection<Manga>.self, from: data)
            
            // Update record for each search item using user's list.
//            for (index, searchItem) in mangaCollection.data.enumerated() {
//                if let existingAnime = animeData.first(where: { searchItem.node.id == $0.node.id}) {
//                    mangaCollection.data[index].record = existingAnime.record
//                }
//            }
            
            return .success(mangaCollection)
            
        } catch {
            print("\(TAG) Error calling fetchMangas(title: \(title)) \n \(error)")
            return .failure(error)
        }
    }
    
    /// Retrieves mangas from MyAnimeList using anime's type.
    /// - Parameters:
    ///     - animeType: Type of media. (ex. anime, manga, novels)
    ///     - page: For paging
    /// - Returns: List of mangas from MyAnimeList using that id.
    func fetchMangas(animeType: AnimeType, page: Int) async -> Result<AnimeCollection<Manga>, Error> {
        do {
            let offset = page * limit
            guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/manga/ranking?ranking_type=\(animeType.rawValue)&fields=\(MyAnimeListApi.mangaField)&limit=\(limit)&offset=\(offset)") else { throw FetchError.badRequest }
            
            var request = URLRequest(url: url)
            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw FetchError.badRequest
            }
            
            let mangaData = try JSONDecoder().decode(AnimeCollection<Manga>.self, from: data)
            return .success(mangaData)
        } catch {
            print("\(TAG) Error calling fetchMangas(animeType: \(animeType), page: \(page)) \n \(error)")
            return .failure(error)
        }
    }
    
    func save(item: WeebItem, seen: Int) async -> Result<CKRecord, Error> {
        do {
            // Fetch record if it exists
            let userID = try await container.userRecordID()
            let recordToMatch = CKRecord.Reference(recordID: userID, action: .deleteSelf) // if user is deleted, delte this record too
            let predicate = NSPredicate(format: "creatorUserRecordID == %@ AND animeID == %d", recordToMatch, item.id) // %d for integers
            let query = CKQuery(recordType: .progress, predicate: predicate)
            let (results, _) = try await database.records(matching: query, resultsLimit: 1)
        
            if let record = try results.first?.1.get() {
                // Record found
                record[.seen] = seen    // update progress
                try await database.save(record) // sucess if record is new or modified.
                print("Sucessfully modified item \(item.getTitle())")
                return .success(record)
            } else {
                // No record found, create it
                var record = Progress(animeID: item.id, animeType: item.getWeebItemType(), seen: seen).record
                try await database.save(record)
                print("Sucessfully save item  \(item.getTitle())")
                return .success(record)
            }
        } catch {
            print("Error saving item \(item.getTitle()): \(error))")
            return .failure(error)
        }
    }
    
//    /// Saves anime to public database as Anime records.
//    /// - Parameters:
//    ///     - animeNode: Anime that we using to extract relevant info
//    /// - Returns: List of mangas from MyAnimeList using that id.
//    func addOrUpdate(animeNode: AnimeNode) async {
//        if animeData.contains(where: { $0.node.id == animeNode.node.id }) {
//            await updateAnime(animeNode: animeNode)
//        } else {
//            await addAnime(animeNode: animeNode)
//        }
//    }
//
//    func updateAnime(animeNode: AnimeNode) async {
//        // update locally
//        guard let index = animeData.firstIndex(where: { $0.node.id == animeNode.node.id }) else { return }
//        animeData[index].record.seen = animeNode.record.seen
//        animeData[index].record.animeID = animeNode.record.animeID
//        animeData[index].record.animeType = animeNode.node.animeType
//        animeData[index].record.modificationDate = Date()
//
//        do {
//            let (saveResult, _) = try await database.modifyRecords(saving: [animeNode.record.record], deleting: [], savePolicy: .changedKeys)
//
//            for (_, result) in saveResult {
//                switch result {
//                case .success(_):
//                    print("\(TAG) Updated record sucessfully")
//                case .failure(let error):
//                    print("\(TAG) Error updaing anime: \(error.localizedDescription)")
//                }
//            }
//        } catch {
//            print("\(TAG) Error calling modifyRecords(): \(error.localizedDescription)")
//        }
//    }
//
//    func addAnime(animeNode: AnimeNode) async {
//        do {
//            animeData.append(animeNode)
//            try await database.save(animeNode.record.record)
//            print("\(TAG) Added record successfully")
//        } catch {
//            print("\(TAG) Error adding anime: \(error)")
//        }
//    }
//
//
    /// Delete an Anime record.
    /// - Parameters:
    ///     - animeNode: Anime object containing record to delete from CloudKit.
    func deleteAnime(weebItem: WeebItem) async {
        do {
            guard let recordID = weebItem.progress?.recordID else { return }// Delete locally            
            try await database.deleteRecord(withID: recordID)
            print("\(TAG) Successfully removed \(weebItem.title).")
        } catch {
            print("\(TAG) Failed to remove \(weebItem.title) \n \(error)")
        }
    }
//
    /// Retrieves animes and mangas using Anime records from Cloudkit.
    /// - Parameters:
    ///     - records: List of Anime records.
    /// - Returns: Animes from MyAnimeList.
    func fetchAnimeAndManga(records: [CKRecord]) async -> [WeebItem] {
        var animes: [WeebItem] = []
        do {
            for record in records {
                guard let type = record[.animeType] as? String else { continue }
                guard let animeType = AnimeType(rawValue: type) else { continue }
                guard let animeID = record[.animeID] as? Int else { continue }

                if animeType == .anime {
                    var node = try await self.fetchAnime(animeID: animeID).get()
                    node.progress = Progress(record: record)
                    animes.append(node)
                } else {
                    var node = try await self.fetchManga(mangaID: animeID).get()
                    node.progress = Progress(record: record)
                    animes.append(node)
                }
            }

            animeData.append(contentsOf: animes)
        } catch {
            print("Error fetching animes using records: \(error)")
            return []
        }
        return animes
    }
    
    /// Retrieves ALL anime records of current user and store locally.
    func loadUserAnimeList() {
        fetchRecords { records in
            print("\(self.TAG) Fetched user's records")
            Task {
                self.animeData = await self.fetchAnimeAndManga(records: records)
            }
        }
    }

    /// https://medium.com/swift-blondie/cloudkit-helper-4643cd73b0be
    /// Retrieves all records satifying the query.
    /// Recursively calls itself, passing next cursor to get next batch until we get all the records.
    /// - Parameters:
    ///     - cursor:  An object that marks the stopping point for a query and the starting point for retreivign the remaining results
    ///     - completionHandler: Returned result after function is done calling.
    /// - Returns: Returns all records using the query.
    func fetchRecords(cursor: CKQueryOperation.Cursor? = nil, completion: @escaping (([CKRecord]) -> Void)) {
        guard let userID = userID else { return }
        let recordToMatch = CKRecord.Reference(recordID: userID, action: .none)
        // different name from cloudkit dashboard for some reason. Also need to add index to make it queryable
        let predicate = NSPredicate(format: "creatorUserRecordID == %@", recordToMatch)
        let query = CKQuery(recordType: .progress, predicate: predicate)
        query.sortDescriptors = [
            // Schema -> Indexes -> Anime -> Add basic index -> modifiedTimestamp (different name) https://developer.apple.com/documentation/cloudkit/ckrecord/1462227-modificationdate
            NSSortDescriptor(key: "modificationDate", ascending: false)
        ]
        
        let operation: CKQueryOperation
        if let cursor = cursor { // if cursor exist, means there is more data to be fetched
            operation = CKQueryOperation(cursor: cursor)
        } else { // inital query
            operation = CKQueryOperation(query: query)
        }
        
        var records: [CKRecord] = []
        operation.recordMatchedBlock = { (recordID, result) in
            switch result {
            case .success(let record):
                records.append(record)
            case .failure(let error):
                print("Error with recordMatchedBlock: \(error)")
            }
        }
        
        operation.queryResultBlock = { result in
            switch result {
            case .success(let cursor):
                if let cursor = cursor {
                    self.fetchRecords(cursor: cursor) { fetchedRecords in
                        records.append(contentsOf: fetchedRecords)
                        completion(records)
                    }
                } else {
                    completion(records)
                }
            case .failure(let error):
                print("Error with queryResultBlock: \(error)")
            }
        }
        
//        operation.resultsLimit = 3
        database.add(operation)
    }
}

enum FetchError: Error {
    case badRequest
    case badJson
    case badURL
    case missingResponse
}

