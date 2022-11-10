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
    
    init(id: Int, title: String, main_picture: Poster, num_episodes: Int, genres: [Genre], studios: [Studio], mean: Float, rank: Int, start_season: Season, synopsis: String, status: String, average_episode_duration: Int, media_type: String) {
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
                genres: [Anime.Genre(name: "Action"), Anime.Genre(name: "Adventure")],
                studios: [Anime.Studio(name: "Toei Animation")],
                mean: 8.42,
                rank: 152,
                start_season: Anime.Season(year: 2015, season: "spring"),
                synopsis: "Gol D. Roger was known as the Pirate King, the strongest and most infamous being to have sailed the Grand Line. The capture and execution of Roger by the World Government brought a change throughout the world. His last words before his",
                status: "ongoing",
                average_episode_duration: 1440,
                media_type: "tv"
            )
        )
    ]
}
