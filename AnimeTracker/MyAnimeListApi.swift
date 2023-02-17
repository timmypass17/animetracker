//
//  MyAnimeListApiService.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/12/23.
//

import Foundation

protocol MyAnimeListApiService {
    
    /// Retrieves specific anime from MyAnimeList database using anime's id.
    /// - Parameters:
    ///     - animeID: Anime's identifier.
    /// - Returns: Anime from MyAnimeList.
    func fetchAnime(animeID: Int) async throws -> AnimeNode

    /// Retrieves animes from MyAnimeList with title to query with.
    /// - Parameters:
    ///     - title: Name of anime.
    /// - Returns: List of animes from MyAnimeList relating to title query.
    func fetchAnimes(title: String) async throws
    
    func fetchAnimesBySeason(page: Int, season: Season, year: Int) async throws -> AnimeCollection
    
    func fetchMangaByID(id: Int, animeType: AnimeType) async throws -> AnimeNode

    func fetchMangasByType(page: Int, animeType: AnimeType) async throws -> AnimeCollection 
}

protocol CloudKitService {
    
    func saveAnime(animeNode: AnimeNode) async

    func fetchAnimesFromCloudKit() async
    
    func deleteAnime(animeNode: AnimeNode) async
}


struct MyAnimeListApi {
    static var fieldValues: String = Anime.CodingKeys.allCases.map { $0.rawValue }.joined(separator: ",")
    static var baseUrl = "https://api.myanimelist.net/v2"
    static var apiKey = "e7bc56aa1b0ea0afe3299d889922e5b8"
}
