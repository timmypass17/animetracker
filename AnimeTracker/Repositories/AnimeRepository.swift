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
    private var userID: CKRecord.ID?
    
    init() {
        Task {
            userID = try await container.userRecordID()
            fetchAnimesFromCloudKit()
            //            let user = getCurrentUser()
        }
    }
    
    
    func fetchAnimesFromCloudKit() {
        fetchRecords { [self] records in
            Task {
                animeData = await fetchAnimeManga(records: records)
            }
        }
    }
    
    /// Retrieves animes and mangas using Anime records from Cloudkit.
    /// - Parameters:
    ///     - records: List of Anime records.
    /// - Returns: Animes from MyAnimeList.
    func fetchAnimeManga(records: [CKRecord]) async -> [AnimeNode] {
        var animes: [AnimeNode] = []
        do {
            for record in records {
                guard let type = record[.animeType] as? String else { continue }
                guard let animeType = AnimeType(rawValue: type) else { continue }
                guard let animeID = record[.animeID] as? Int else { continue }
                
                var node: AnimeNode
                if animeType == .anime {
                    node = try await self.fetchAnime(animeID: animeID)
                } else {
                    node = try await self.fetchManga(mangaID: animeID)
                }
                node.record = AnimeRecord(record: record)
                animes.append(node)
            }
            
            animeData.append(contentsOf: animes)
        } catch {
            print("Error fetching animes using records: \(error)")
            return []
        }
        return animes
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
        let query = CKQuery(recordType: "Anime", predicate: predicate)
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
                //                print("Adding record")
                records.append(record)
            case .failure(let error):
                print("Error with recordMatchedBlock: \(error)")
            }
        }
        
        operation.queryResultBlock = { result in
            switch result {
            case .success(let cursor):
                if let cursor = cursor {
                    //                    print("Found cursor, fetching more records")
                    self.fetchRecords(cursor: cursor) { fetchedRecords in
                        records.append(contentsOf: fetchedRecords)
                        //                        print("queryResultBlock handler: \(records.count)")
                        completion(records)
                    }
                } else {
                    //                    print("no more cursor: \(records.count)")
                    completion(records)
                }
            case .failure(let error):
                print("Error with queryResultBlock: \(error)")
            }
        }
        
        operation.resultsLimit = 3
        database.add(operation)
    }
    
    public typealias YourFetchCompletionHandler = (_ records: [CKRecord]?, _ cursor: CKQueryOperation.Cursor?) -> (Void)
    
    /// https://stackoverflow.com/questions/48965667/batch-fetching-with-cloudkit-ckqueryoperation
    /// Retrieves x amount of records and next cursor (that points to the next x records).
    /// - Parameters:
    ///     - isFirstFetch: To solve infinite loop
    ///     - cursor:  An object that marks the stopping point for a query and the starting point for retreivign the remaining results
    ///     - completionHandler: Returned result after function is done calling.
    /// - Returns: Returns the batch of records and a cursor pointing to the next batch.
    public func fetchRecordsInBatches(isFirstFetch: Bool, _ cursor: CKQueryOperation.Cursor? = nil, completionHandler handler: @escaping YourFetchCompletionHandler) -> Void {
        guard let userID = userID else { return }
        
        let recordToMatch = CKRecord.Reference(recordID: userID, action: .none)
        // different name from cloudkit dashboard for some reason. Also need to add index to make it queryable
        let predicate = NSPredicate(format: "creatorUserRecordID == %@", recordToMatch)
        let query = CKQuery(recordType: "Anime", predicate: predicate)
        query.sortDescriptors = [
            // Schema -> Indexes -> Anime -> Add basic index -> modifiedTimestamp (different name) https://developer.apple.com/documentation/cloudkit/ckrecord/1462227-modificationdate
            NSSortDescriptor(key: "modificationDate", ascending: false)
        ]
        
        var operation: CKQueryOperation
        
        if isFirstFetch {
            print("first fetch")
            // Create the operation for the first time
            operation = CKQueryOperation(query: query)
        } else if let cursor = cursor {
            print("got cursor")
            // Operation to fetch another 10 records.
            operation = CKQueryOperation(cursor: cursor)
        } else {
            print("end of fetching")
            // If not first time and if cursor is nil (which means
            // there is no more data) then return empty array
            // or whatever you want
            
            handler([], nil)
            return
        }
        
        var records: [CKRecord] = [CKRecord]()
        
        operation.recordMatchedBlock = { (recordID, result) in
            switch result {
            case .success(let record):
                print("Adding record")
                records.append(record)
            case .failure(let error):
                print("Error with recordMatchedBlock: \(error)")
            }
        }
        
        operation.queryResultBlock = { result in
            switch result {
            case .success(let cursor):
                if let cursor = cursor {
                    print("Passing cursor")
                    handler(records, cursor)
                } else {
                    print("no more cursor")
                    handler(records, nil)
                }
            case .failure(let error):
                print("Error with queryResultBlock: \(error)")
            }
        }
        
        // Fetch only 3 records
        operation.resultsLimit = 3
        database.add(operation)
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
            var animeNode = AnimeNode(node: anime)
//            // update record if it exist
//            if let index = animeData.firstIndex(where: { $0.node.id == animeID }){
//                print("update record")
//                animeNode.record = animeData[index].record
//            } else {
//                print("no record")
//            }
            return animeNode
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
        print(titleFormatted)
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
    func addOrUpdate(animeNode: AnimeNode) async {
        if animeData.contains(where: { $0.node.id == animeNode.node.id }) {
            await updateAnime(animeNode: animeNode)
        } else {
            await addAnime(animeNode: animeNode)
        }
    }
    
    func updateAnime(animeNode: AnimeNode) async {
        // update locally
        guard let index = animeData.firstIndex(where: { $0.node.id == animeNode.node.id }) else { return }
        animeData[index].record.seen = animeNode.record.seen
        animeData[index].record.animeID = animeNode.record.animeID
        animeData[index].record.animeType = animeNode.node.animeType
        
        do {
            let (saveResult, _) = try await database.modifyRecords(saving: [animeNode.record.record], deleting: [], savePolicy: .changedKeys)
            
            for (_, result) in saveResult {
                switch result {
                case .success(_):
                    print("\(TAG) Updated record sucessfully")
                case .failure(let error):
                    print("\(TAG) Error updaing anime: \(error.localizedDescription)")
                }
            }
        } catch {
            print("\(TAG) Error calling modifyRecords(): \(error.localizedDescription)")
        }
    }
    
    func addAnime(animeNode: AnimeNode) async {
        do {
            animeData.append(animeNode)
            try await database.save(animeNode.record.record)
            print("\(TAG) Added record successfully")
        } catch {
            print("\(TAG) Error adding anime: \(error)")
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

