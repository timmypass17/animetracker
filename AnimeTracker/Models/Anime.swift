//
//  Anime.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import Foundation
import CloudKit

// Make your data types encodable and decodable for compatibility with external representations such as JSON.
// Note: 1. Need to mirror JSON result
//       2. Use coding keys to add aditional fields not found in json structure

struct MyAnimeListApi {
    static let fieldValues = ["num_episodes", "genres", "mean", "rank", "start_season", "synopsis", "studios", "status", "average_episode_duration", "media_type", "alternative_titles", "popularity", "num_list_users"]
}

struct AnimeCollection: Codable {
    var data: [AnimeNode]
}

struct AnimeNode: Codable {
    
    enum CodingKeys: String, CodingKey {
        case node // if u want to add additinal fields, you have to explicitly list the nodes that ARE in the json structure
    }
    
    var node: Anime
    var record: CKRecord = CKRecord(recordType: "Anime")
}

struct Anime: Codable {
    var id: Int
    var title: String
    var main_picture: Poster
    var num_episodes: Int
    var genres: [Genre]
    var studios: [Studio]
    var mean: Float
    var rank: Int
    var start_season: Season
    var synopsis: String
    var status: String
    var average_episode_duration: Int // seconds
    var media_type: String
    var alternative_titles: AlternativeTitle
    var popularity: Int
    var num_list_users: Int
    
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
    
    init(id: Int, title: String, main_picture: Poster, num_episodes: Int, genres: [Genre], studios: [Studio], mean: Float, rank: Int, start_season: Season, synopsis: String, status: String, average_episode_duration: Int, media_type: String, alternative_titles: AlternativeTitle, popularity: Int, num_list_users: Int) {
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
    }
}

extension AnimeCollection {
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
                num_list_users: 480628
            )
        )
    ]
}
