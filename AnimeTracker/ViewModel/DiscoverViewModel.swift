//
//  DiscoverViewModel.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/13/23.
//

import SwiftUI


@MainActor
class DiscoverViewModel: ObservableObject {
//    @Published var topAiringData: [AnimeNode] = []
//    @Published var topUpcomingData: [AnimeNode] = []
    @Published var fallData: [AnimeNode] = []
    @Published var summerData: [AnimeNode] = []
    @Published var springData: [AnimeNode] = []
    @Published var winterData: [AnimeNode] = []
    
    @Published var fallYear: Int = 2022
    @Published var summerYear: Int = 2022
    @Published var springYear: Int = 2022
    @Published var winterYear: Int = 2022

    init() {
        Task {
            // Calculate 4 recent years
            
//            topAiringData = try await fetchAnimeByRank(rankingType: .airing)
//            topUpcomingData = try await fetchAnimeByRank(rankingType: .upcoming)
            fallData = try await fetchAnimeBySeason(season: .fall, year: getCurrentYear() - 1, limit: 15)
            summerData = try await fetchAnimeBySeason(season: .summer, year: getCurrentYear() - 1, limit: 15)
            springData = try await fetchAnimeBySeason(season: .spring, year: getCurrentYear() - 1, limit: 15)
            winterData = try await fetchAnimeBySeason(season: .winter, year: getCurrentYear() - 1, limit: 15)

        }
    }
    
    func getCurrentYear() -> Int {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: date)
        return Int(yearString)!
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
}

enum Ranking: String {
    case all, airing, upcoming, bypopularity
}

enum Season: String {
    case winter, spring, summer, fall
}
