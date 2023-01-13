//
//  MyAnimeListApiService.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/12/23.
//

import Foundation

protocol MyAnimeListApiService {
    
    func fetchAnimeByID(id: Int) async throws -> AnimeNode
    
    func fetchAnimesByTitle(title: String) async throws

}

protocol CloudKitService {
    
    func addAnime(animeNode: AnimeNode) async

    func fetchAnimes() async
    
    func deleteAnime(animeNode: AnimeNode) async
}


struct MyAnimeListApi {
    static var fieldValues: [String] = ["num_episodes", "genres", "mean", "rank", "start_season", "synopsis", "studios", "status", "average_episode_duration", "media_type", "alternative_titles", "popularity", "num_list_users", "source", "rating", "related_anime", "recommendations"]
    static var baseUrl = "https://api.myanimelist.net/v2"
    static var apiKey = "e7bc56aa1b0ea0afe3299d889922e5b8"
}
