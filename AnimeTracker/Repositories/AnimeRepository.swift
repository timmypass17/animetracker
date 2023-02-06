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
    @Published var fallData = AnimeCollection()
    @Published var summerData = AnimeCollection()
    @Published var springData = AnimeCollection()
    @Published var winterData = AnimeCollection()
    
    @Published var fallDataPrev = AnimeCollection()
    @Published var summerDataPrev = AnimeCollection()
    @Published var springDataPrev = AnimeCollection()
    @Published var winterDataPrev = AnimeCollection()

    @Published var searchResults: [AnimeNode] = []
    
    @Published var mangaData = AnimeCollection()
    @Published var novelData = AnimeCollection()
    @Published var manhwaData = AnimeCollection()
    @Published var manhuaData = AnimeCollection()
    
    let container: CKContainer = CKContainer.default()
    var database: CKDatabase {
        container.publicCloudDatabase
    }
    let TAG = "[AnimeRepository]"
    let limit = 10
    
    init() {
        Task {
            await fetchAnimesFromCloudKit()
            do {
                let currentYear = getCurrentYear()
                fallData = try await fetchAnimesBySeason(season: .fall, year: currentYear)
                summerData = try await fetchAnimesBySeason(season: .summer, year: currentYear)
                springData = try await fetchAnimesBySeason(season: .spring, year: currentYear)
                winterData = try await fetchAnimesBySeason(season: .winter, year: currentYear)

                fallDataPrev = try await fetchAnimesBySeason(season: .fall, year: currentYear - 1)
                summerDataPrev = try await fetchAnimesBySeason(season: .summer, year: currentYear - 1)
                springDataPrev = try await fetchAnimesBySeason(season: .spring, year: currentYear - 1)
                winterDataPrev = try await fetchAnimesBySeason(season: .winter, year: currentYear - 1)

                mangaData = try await fetchMangasByRanking(rankingType: .manga, limit: 10)
                novelData = try await fetchMangasByRanking(rankingType: .novels, limit: 10)
                manhwaData = try await fetchMangasByRanking(rankingType: .manhwa, limit: 10)
                manhuaData = try await fetchMangasByRanking(rankingType: .manhua, limit: 10)

            } catch {
                print(error)
            }
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
        var anime = try JSONDecoder().decode(Anime.self, from: data)
        anime.animeType = .anime
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
            searchResults[index].node.animeType = .anime
            for item in animeData {
                if item.node.id == animeNode.node.id {
                    searchResults[index].record = item.record
                }
            }
        }
    }
    
    func fetchAnimesByRanking(rankingType: Ranking) async throws -> [AnimeNode] {
        let fieldValue = MyAnimeListApi.fieldValues.joined(separator: ",")
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime/ranking?ranking_type=\(rankingType.rawValue)&fields=\(fieldValue)") else { throw FetchError.badRequest }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        
        do {
            let animes = try JSONDecoder().decode(AnimeCollection.self, from: data).data
            return animes
        } catch {
            print(error)
        }
        
        return []
    }
    
    func fetchAnimesBySeason(season: Season, year: Int) async throws -> AnimeCollection {
        let fieldValue = MyAnimeListApi.fieldValues.joined(separator: ",")
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/anime/season/\(year)/\(season.rawValue)?sort=&anime_score&fields=\(fieldValue)&limit=\(limit)") else {
            throw FetchError.badRequest }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("bad response")
            return AnimeCollection()
            //            throw FetchError.badRequest
        }
        
        // get anime data from rest api
        do {
            var result = try JSONDecoder().decode(AnimeCollection.self, from: data)
            result.data.indices.forEach {
                result.data[$0].node.animeType = .anime
            }
            return result
            //            return animes.sorted(by: { $0.node.mean ?? 0.0 > $1.node.mean ?? 0.0 })
        } catch {
            print(error)
        }
        
        return AnimeCollection()
    }
    
    func fetchMangaByID(id: Int) async throws -> AnimeNode {
        let fieldValue = MyAnimeListApi.fieldValues.joined(separator: ",")
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/manga/\(id)?fields=\(fieldValue)") else { throw FetchError.badRequest }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        
        // get anime data from rest api
        var manga = try JSONDecoder().decode(Anime.self, from: data)
        manga.animeType = .manga
        return AnimeNode(node: manga)
    }
    
    func fetchMangasByRanking(rankingType: Ranking, limit: Int = 100) async throws -> AnimeCollection {
        let fieldValue = MyAnimeListApi.fieldValues.joined(separator: ",")
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/manga/ranking?ranking_type=\(rankingType.rawValue)&fields=\(fieldValue)&limit=\(limit)") else { throw FetchError.badRequest }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        
        do {
            var result = try JSONDecoder().decode(AnimeCollection.self, from: data)
            result.data.indices.forEach {
                result.data[$0].node.animeType = .manga
            }
            return result
        } catch {
            print(error)
        }
        return AnimeCollection()
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
                "episodes_seen": animeNode.episodes_seen,
                "type": animeNode.node.animeType?.rawValue ?? "wtf" // update animeType field during every network request
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
    
}

func getCurrentYear() -> Int {
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    let yearString = dateFormatter.string(from: date)
    return Int(yearString)!
}

extension AnimeRepository {
    // Determine which data to go to. I just hardcoded it :(
    // (fall 2023, summer 2023, spring 2023, winter 2023, fall 2022, summer 2022, spring 2022, winter 2022)
    func loadMore(season: Season, year: Int) async throws {
        let currentYear = getCurrentYear()
        // fall (current year)
        if season == .fall && year == currentYear {
            guard let query = fallData.paging.next else { return }
            guard let url = URL(string: query) else { throw FetchError.badRequest }
            var request = URLRequest(url: url)
            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("bad response")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AnimeCollection.self, from: data)
                var animes = result.data
                animes.indices.forEach {
                    animes[$0].node.animeType = .anime
                }
                for anime in animes {
                    fallData.data.append(anime)
                    //                fallData.append(anime)
                }
                fallData.paging.next = result.paging.next
            } catch {
                print(error)
            }
        }
        // summer (current year)
        else if season == .summer && year == currentYear {
            guard let query = summerData.paging.next else { return }
            guard let url = URL(string: query) else { throw FetchError.badRequest }
            var request = URLRequest(url: url)
            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("bad response")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AnimeCollection.self, from: data)
                var animes = result.data
                animes.indices.forEach {
                    animes[$0].node.animeType = .anime
                }
                for anime in animes {
                    summerData.data.append(anime)
                    //                fallData.append(anime)
                }
                summerData.paging.next = result.paging.next
            } catch {
                print(error)
            }
        }
        
        // spring (currrent year)
        else if season == .spring && year == currentYear {
            guard let query = springData.paging.next else { return }
            guard let url = URL(string: query) else { throw FetchError.badRequest }
            var request = URLRequest(url: url)
            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("bad response")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AnimeCollection.self, from: data)
                var animes = result.data
                animes.indices.forEach {
                    animes[$0].node.animeType = .anime
                }
                for anime in animes {
                    springData.data.append(anime)
                    //                fallData.append(anime)
                }
                springData.paging.next = result.paging.next
            } catch {
                print(error)
            }
        }
        
        // winter (current year)
        else if season == .winter && year == currentYear {
            guard let query = winterData.paging.next else { return }
            guard let url = URL(string: query) else { throw FetchError.badRequest }
            var request = URLRequest(url: url)
            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("bad response")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AnimeCollection.self, from: data)
                var animes = result.data
                animes.indices.forEach {
                    animes[$0].node.animeType = .anime
                }
                for anime in animes {
                    winterData.data.append(anime)
                    //                fallData.append(anime)
                }
                winterData.paging.next = result.paging.next
            } catch {
                print(error)
            }
        }
        
        // fall (last year)
        else if season == .fall && year == currentYear - 1 {
            print("\(season) \(year)")
            guard let query = fallDataPrev.paging.next else { return }
            guard let url = URL(string: query) else { throw FetchError.badRequest }
            var request = URLRequest(url: url)
            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("bad response")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AnimeCollection.self, from: data)
                var animes = result.data
                animes.indices.forEach {
                    animes[$0].node.animeType = .anime
                }
                for anime in animes {
                    fallDataPrev.data.append(anime)
                    //                fallData.append(anime)
                }
                fallDataPrev.paging.next = result.paging.next
            } catch {
                print(error)
            }
        }
        // summer (last year)
        else if season == .summer && year == currentYear - 1 {
            print("\(season) \(year)")
            guard let query = summerDataPrev.paging.next else { return }
            guard let url = URL(string: query) else { throw FetchError.badRequest }
            var request = URLRequest(url: url)
            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("bad response")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AnimeCollection.self, from: data)
                var animes = result.data
                animes.indices.forEach {
                    animes[$0].node.animeType = .anime
                }
                for anime in animes {
                    summerDataPrev.data.append(anime)
                    //                fallData.append(anime)
                }
                summerDataPrev.paging.next = result.paging.next
            } catch {
                print(error)
            }
        }
        // spring (last year)
        else if season == .spring && year == currentYear - 1 {
            guard let query = springDataPrev.paging.next else { return }
            guard let url = URL(string: query) else { throw FetchError.badRequest }
            var request = URLRequest(url: url)
            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("bad response")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AnimeCollection.self, from: data)
                var animes = result.data
                animes.indices.forEach {
                    animes[$0].node.animeType = .anime
                }
                for anime in animes {
                    springDataPrev.data.append(anime)
                    //                fallData.append(anime)
                }
                springDataPrev.paging.next = result.paging.next
            } catch {
                print(error)
            }
        }
        
        // winter (last year)
        else if season == .winter && year == currentYear - 1 {
            guard let query = winterDataPrev.paging.next else { return }
            guard let url = URL(string: query) else { throw FetchError.badRequest }
            var request = URLRequest(url: url)
            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("bad response")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AnimeCollection.self, from: data)
                var animes = result.data
                animes.indices.forEach {
                    animes[$0].node.animeType = .anime
                }
                for anime in animes {
                    winterDataPrev.data.append(anime)
                    //                fallData.append(anime)
                }
                winterDataPrev.paging.next = result.paging.next
            } catch {
                print(error)
            }
        }
        else {
            print("loadMore() invalid input: \(season) \(year)")
        }
    }
    
    func fetchMangas(page: Int) async throws -> AnimeCollection {
        print(page)
        let fieldValue = MyAnimeListApi.fieldValues.joined(separator: ",")
        let offset = page * limit
        guard let url = URL(string: "\(MyAnimeListApi.baseUrl)/manga/ranking?ranking_type=manga&fields=\(fieldValue)&limit=\(limit)&offset=\(offset)") else { throw FetchError.badRequest }
        
        var request = URLRequest(url: url)
        request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        
        do {
            var mangaData = try JSONDecoder().decode(AnimeCollection.self, from: data)
            mangaData.data.indices.forEach { mangaData.data[$0].node.animeType = .manga }
            return mangaData
        } catch {
            print(error)
        }
        return AnimeCollection()
    }
    
//    func loadMoreManga(ranking: String) async throws {
//        if ranking == "manga" {
//            guard let query = mangaData.paging.next else { return }
//            guard let url = URL(string: query) else { throw FetchError.badRequest }
//            var request = URLRequest(url: url)
//            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
//            let (data, response) = try await URLSession.shared.data(for: request)
//            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
//                print("bad response")
//                return
//            }
//
//            do {
//                let result = try JSONDecoder().decode(AnimeCollection.self, from: data)
//                var mangas = result.data
//                mangas.indices.forEach {
//                    mangas[$0].node.animeType = .anime
//                }
//                for manga in mangas {
//                    mangaData.data.append(manga)
//                    //                fallData.append(anime)
//                }
//                mangaData.paging.next = result.paging.next
//            } catch {
//                print(error)
//            }
//        } else if ranking == "novels" {
//            guard let query = novelData.paging.next else { return }
//            guard let url = URL(string: query) else { throw FetchError.badRequest }
//            var request = URLRequest(url: url)
//            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
//            let (data, response) = try await URLSession.shared.data(for: request)
//            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
//                print("bad response")
//                return
//            }
//
//            do {
//                let result = try JSONDecoder().decode(AnimeCollection.self, from: data)
//                var mangas = result.data
//                mangas.indices.forEach {
//                    mangas[$0].node.animeType = .anime
//                }
//                for manga in mangas {
//                    novelData.data.append(manga)
//                }
//                novelData.paging.next = result.paging.next
//            } catch {
//                print(error)
//            }
//        } else if ranking == "manhwa" {
//            guard let query = manhwaData.paging.next else { return }
//            guard let url = URL(string: query) else { throw FetchError.badRequest }
//            var request = URLRequest(url: url)
//            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
//            let (data, response) = try await URLSession.shared.data(for: request)
//            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
//                print("bad response")
//                return
//            }
//
//            do {
//                let result = try JSONDecoder().decode(AnimeCollection.self, from: data)
//                var mangas = result.data
//                mangas.indices.forEach {
//                    mangas[$0].node.animeType = .anime
//                }
//                for manga in mangas {
//                    manhwaData.data.append(manga)
//                }
//                manhwaData.paging.next = result.paging.next
//            } catch {
//                print(error)
//            }
//        } else {
//            guard let query = manhuaData.paging.next else { return }
//            guard let url = URL(string: query) else { throw FetchError.badRequest }
//            var request = URLRequest(url: url)
//            request.setValue(MyAnimeListApi.apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
//            let (data, response) = try await URLSession.shared.data(for: request)
//            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
//                print("bad response")
//                return
//            }
//
//            do {
//                let result = try JSONDecoder().decode(AnimeCollection.self, from: data)
//                var mangas = result.data
//                mangas.indices.forEach {
//                    mangas[$0].node.animeType = .anime
//                }
//                for manga in mangas {
//                    manhuaData.data.append(manga)
//                }
//                manhuaData.paging.next = result.paging.next
//            } catch {
//                print(error)
//            }
//        }
    
}

