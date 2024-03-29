//
//  MyAnimeListApiService.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/12/23.
//

import Foundation

protocol MyAnimeListApiService {
    
//    func fetchAnime(animeID: Int) async -> Result<AnimeNode, Error>
//
//    func fetchAnimes(title: String) async -> Result<AnimeCollection, Error>
//
//    func fetchAnimes(season: Season, year: Int, page: Int) async throws -> AnimeCollection
//
//    func fetchManga(mangaID: Int) async throws -> AnimeNode
//    
//    func fetchMangas(title: String) async throws -> AnimeCollection
//
//    func fetchMangas(animeType: AnimeType, page: Int) async throws -> AnimeCollection
}

struct MyAnimeListApi {
    static var animeField: String = Anime.CodingKeys.allCases.map { $0.rawValue }.joined(separator: ",")
    static var mangaField: String = Manga.CodingKeys.allCases.map { $0.rawValue }.joined(separator: ",")
    static var baseUrl = "https://api.myanimelist.net/v2"
    static var apiKey = "e7bc56aa1b0ea0afe3299d889922e5b8"
}
