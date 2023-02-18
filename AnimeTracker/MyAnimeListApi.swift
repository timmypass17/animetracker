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
    ///     - animeID: Anime's unique identifier.
    /// - Returns: Anime from MyAnimeList with that id.
    func fetchAnime(animeID: Int) async throws -> AnimeNode

    /// Retrieves animes from MyAnimeList with title to query with.
    /// - Parameters:
    ///     - title: Name of anime.
    /// - Returns: List of animes from MyAnimeList relating to title query.
    func fetchAnimes(title: String) async throws
    
    /// Retrieves animes from MyAnimeList from that season and year.
    /// - Parameters:
    ///     - season: Starting season of anime. (ex. fall)
    ///     - year: Starting year of anime.
    /// - Returns: List of animes from MyAnimeList from that season and year.
    func fetchAnimesBySeason(season: Season, year: Int, page: Int) async throws -> AnimeCollection
    
    /// Retrieves mangas from MyAnimeList using manga's id.
    /// - Parameters:
    ///     - mangaID: Manga's unique identifier
    ///     - animeType: manga, novel, etc..
    /// - Returns: List of mangas from MyAnimeList using that id.
    func fetchMangaByID(mangaID: Int) async throws -> AnimeNode

    func fetchMangasByType(animeType: AnimeType, page: Int) async throws -> AnimeCollection
}

struct MyAnimeListApi {
    static var fieldValues: String = Anime.CodingKeys.allCases.map { $0.rawValue }.joined(separator: ",")
    static var baseUrl = "https://api.myanimelist.net/v2"
    static var apiKey = "e7bc56aa1b0ea0afe3299d889922e5b8"
}
