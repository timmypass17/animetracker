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
    
    func fetchAnimeByRank(rankingType: Ranking) async throws -> [AnimeNode]
    
    func fetchAnimeBySeason(season: Season, year: Int, limit: Int) async throws -> [AnimeNode]
}

protocol CloudKitService {
    
    func addAnime(animeNode: AnimeNode) async

    func fetchAnimesFromCloudKit() async
    
    func deleteAnime(animeNode: AnimeNode) async
}


struct MyAnimeListApi {
    static var fieldValues: [String] = ["id", "title", "main_picture", "alternative_titles", "start_date", "end_date", "synopsis", "mean", "rank", "popularity", "num_list_users", "media_type", "status", "genres", "num_episodes", "start_season", "broadcast", "source", "average_episode_duration", "rating", "related_anime", "related_manga", "recommendations", "studios"]
    static var baseUrl = "https://api.myanimelist.net/v2"
    static var apiKey = "e7bc56aa1b0ea0afe3299d889922e5b8"
}
