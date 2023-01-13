//
//  Anime.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import Foundation
import CloudKit


struct AnimeCollection: Codable {
    var data: [AnimeNode]
}

struct AnimeNode: Codable {
    
    // put stuff in json tree here.
    enum CodingKeys: String, CodingKey {
        case node
    }

    var node: Anime
    var record: CKRecord = CKRecord(recordType: "Anime") // not in json tree, so its not in enum. episodes_seen should be inside on cloudkit
    
    // unwrap record fields
    var episodes_seen: Int {
        get { record["episodes_seen"] as? Int ?? 0 }
        set { record["episodes_seen"] = newValue }
    }
    var bookmarked: Bool {
        get { record["bookmarked"] as? Bool ?? false }
        set { record["bookmarked"] = newValue }
    }
}

struct Anime: Codable {
    var id: Int
    var title: String
    var main_picture: Poster
    var num_episodes: Int
    var genres: [Genre]
    var studios: [Studio]
    var mean: Float?    // upcoming animes don't have scores
    var rank: Int?
    var start_season: Season?
    var synopsis: String
    var status: String
    var average_episode_duration: Int // seconds
    var media_type: String
    var alternative_titles: AlternativeTitle
    var popularity: Int
    var num_list_users: Int
    var source: String?
    var rating: String?
    var related_anime: [RelatedNode]? // might not exist for some reason?
//    var related_manga: [RelatedNode] = []
//    var recommendations: [RecommendedNode]? // might not exist for some reason when querying by name (works by querying by id)
    var recommendations: [RelatedNode]?
    
    struct Poster: Codable {
        var medium: String
        var large: String
    }
    struct Genre: Codable, Equatable {
        var name: String
    }
    struct Season: Codable {
        var year: Int
        var season: String
    }
    struct Studio: Codable, Equatable {
        var name: String
    }
    struct AlternativeTitle: Codable {
        var synonyms: [String]
        var en: String
        var ja: String
    }
    
    struct RelatedNode: Codable {
        var node: AnimeNodeSmall
        var relation_type_formatted: String?
    }
    
    struct AnimeNodeSmall: Codable {
        var id: Int
        var title: String
        var main_picture: Poster
    }
    
    init(id: Int = 0, title: String = "", main_picture: Poster = Poster(medium: "", large: ""), num_episodes: Int = 0, genres: [Genre] = [], studios: [Studio] = [], mean: Float? = nil, rank: Int? = nil, start_season: Season? = nil, synopsis: String = "", status: String = "", average_episode_duration: Int = 0, media_type: String = "", alternative_titles: AlternativeTitle = AlternativeTitle(synonyms: [], en: "", ja: ""), popularity: Int = 0, num_list_users: Int = 0, source: String = "", rating: String? = nil, related_anime: [RelatedNode]? = nil, recommendations: [RelatedNode]? = nil) {
        self.id = id
        self.title = title
        self.main_picture = main_picture
        self.num_episodes = num_episodes
        self.genres = genres
        self.studios = studios
        self.mean = mean
        self.rank = rank
        self.start_season = start_season
        self.synopsis = synopsis
        self.status = status
        self.average_episode_duration = average_episode_duration
        self.media_type = media_type
        self.alternative_titles = alternative_titles
        self.popularity = popularity
        self.num_list_users = num_list_users
        self.source = source
        self.rating = rating
        self.related_anime = related_anime
        self.recommendations = recommendations
    }
}

extension Anime {
    // I just organized getters here
    func meanFormatted() -> String {
        guard let mean = mean else { // guard exits scope, if let continues as normal. Just use guard mostly
            return "?"
        }
        
        return String(format: "%.2f", mean)
    }
    
    func rankFormatted() -> String {
        guard let rank = rank else {
            return "?"
        }
        
        return String(rank)
    }
    
    func ratingFormatted() -> String {
        guard let rating = rating else {
            return "?"
        }
        
        return String(rating)
    }
    
    func startSeasonFormatted() -> String {
        guard let start_season = start_season else {
            return "?"
        }
        
        return "\(start_season.season.capitalized) \(start_season.year)"
    }
}

// Make your data types encodable and decodable for compatibility with external representations such as JSON.
// Note: 1. Need to mirror JSON result
//       2. Use coding keys to add aditional fields not found in json structure.
//          - if u want to add additinal fields, you have to explicitly list the nodes that ARE in the json structure

// "related_anime" field doesnt exist when querying using title. (works when querying using id)
//struct MyAnimeListApi {
//    static let fieldValues = ["num_episodes", "genres", "mean", "rank", "start_season", "synopsis", "studios", "status", "average_episode_duration", "media_type", "alternative_titles", "popularity", "num_list_users", "source", "rating", "related_anime", "recommendations"]
//    static let baseUrl = "https://api.myanimelist.net/v2"
//    static let apiKey = "e7bc56aa1b0ea0afe3299d889922e5b8"
//}


extension AnimeCollection {
    static let relatedAnime: Anime.RelatedNode = Anime.RelatedNode(node: Anime.AnimeNodeSmall(id: 1, title: "One Piece Movie", main_picture: Anime.Poster(medium: "https://api-cdn.myanimelist.net/images/anime/6/73245.jpg", large: "https://api-cdn.myanimelist.net/images/anime/6/73245.jpg")), relation_type_formatted: "Prequel")
    
    static let sampleData: [AnimeNode] =
    [
        AnimeNode(
            node: Anime(
                id: 21,
                title: "One Piece",
                main_picture: Anime.Poster(medium: "https://api-cdn.myanimelist.net/images/anime/6/73245.jpg", large: "https://api-cdn.myanimelist.net/images/anime/6/73245.jpg"),
                num_episodes: 973,
                genres: [Anime.Genre(name: "Action"), Anime.Genre(name: "Adventure"), Anime.Genre(name: "Comedy")],
                studios: [Anime.Studio(name: "Toei Animation")],
                mean: 8.42,
                rank: 152,
                start_season: Anime.Season(year: 2015, season: "spring"),
                synopsis: "Gol D. Roger was known as the Pirate King, the strongest and most infamous being to have sailed the Grand Line. The capture and execution of Roger by the World Government brought a change throughout the world. His last words before his",
                status: "ongoing",
                average_episode_duration: 1440,
                media_type: "tv",
                alternative_titles: Anime.AlternativeTitle(synonyms: ["Daiya no Ace: Second Season", "Ace of the Diamond: 2nd Season"], en: "One Piece", ja: "One Piece"),
                popularity: 23,
                num_list_users: 480628,
                source: "manga",
                rating: "pg_13",
                related_anime: [
                    AnimeCollection.relatedAnime
                ],
                recommendations: []
            )
        )
    ]
}
