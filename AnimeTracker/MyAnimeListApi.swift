//
//  MyAnimeListApiService.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/12/23.
//

import Foundation

protocol MyAnimeListApiService {
    
    func fetchAnimeByID(id: Int) async throws -> AnimeNode
    
    func fetchAnimesByTitle(title: String, limit: Int) async throws
    
    func fetchAnimesByRanking(rankingType: Ranking) async throws -> [AnimeNode]
    
    func fetchAnimesBySeason(season: Season, year: Int) async throws -> AnimeCollection
    
    func fetchMangaByID(id: Int) async throws -> AnimeNode

    func fetchMangasByRanking(rankingType: Ranking, limit: Int) async throws -> AnimeCollection
}

protocol CloudKitService {
    
    func addAnime(animeNode: AnimeNode) async

    func fetchAnimesFromCloudKit() async
    
    func deleteAnime(animeNode: AnimeNode) async
}


struct MyAnimeListApi {
    static var fieldValues: [String] = Anime.CodingKeys.allCases.map { $0.rawValue }
    static var baseUrl = "https://api.myanimelist.net/v2"
    static var apiKey = "e7bc56aa1b0ea0afe3299d889922e5b8"
}

enum Ranking: String {
    case manga, novels, manhwa, manhua
}

enum Season: String, CaseIterable, Codable {
    case winter, spring, summer, fall
}
