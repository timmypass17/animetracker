//
//  Anime.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import Foundation
import CloudKit

// might be <T: Codable>

struct AnimeCollection<T: WeebItem>: Codable {
    var data: [AnimeNode<T>] = []
    var season: AnimeSeason?
}

struct AnimeNode<T: WeebItem>: Codable {
    var node: T
}

struct Anime: WeebItem, Codable {
    var id: Int
    var title: String?
    var main_picture: MainPicture?
    var alternative_titles: AlternativeTitle?
    var start_date: String?
    var end_date: String?
    var synopsis: String?
    var mean: Float?
    var rank: Int?
    var popularity: Int?
    var num_list_users: Int?
    var media_type: MediaType?
    var status: AiringStatus?
    var genres: [Genre]?
    var recommendations: [Recommendation]?
    var progress: Progress?
    
    // Extra fields
    var rating: String?
    var num_episodes: Int?
    var start_season: AnimeSeason?
    var broadcast: Broadcast?
    var source: String?
    var average_episode_duration: Int?
    var related_anime: [RelatedItem]?
    var studios: [Studio]?
        
    // infer either anime, manga, novel, etc.. from media type (ex. 'tv' is an anime)
//    var animeType: AnimeType {
//        guard let media_type = media_type else { return .anime }
//
//        switch media_type {
//        case .tv, .ova, .ona, .movie, .special, .music:
//            return .anime
//        case .manga:
//            return .manga
//        case .light_novel, .novel:
//            return .novels
//        case .manhwa:
//            return .manhwa
//        case .manhua:
//            return .manhua
//        case .doujinshi:
//            return .doujin
//        case .one_shot:
//            return .oneshots
//        }
//    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id, title, main_picture, alternative_titles, start_date, end_date, synopsis, mean, rank, popularity, num_list_users, media_type, status, genres, num_episodes, start_season, broadcast, source, average_episode_duration, rating, related_anime, recommendations, studios
    }
}


enum PosterSize {
    case medium, large
}



// MARK: Getters
extension Anime {
    func getRating() -> String {
        return rating ?? "No rating yet."
    }
    
    func getNumEpisodes() -> Int {
        return num_episodes ?? 0
    }

    func getStartSeasonAndYear() -> String {
        guard let start_season = start_season else { return "?" }
        return "\(start_season.season.rawValue.capitalized) \(start_season.year)"
    }

    func getBroadcast() -> String {
        guard let broadcast = broadcast else { return "No broadcast" }
        guard let weekday = broadcast.day_of_the_week else { return "No broadcast" }
        guard let start_time = broadcast.start_time else { return "No broadcast" }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = dateFormatter.date(from: "\(start_time)") // create date object

        if let date = date {
            let dateStr = dateFormatter.string(from: date)
            return "\(weekday.capitalized), \(dateStr) (JSP)"
        }

        return "No broadcast"
    }
    
    func getSource() -> String {
        return source ?? "No source"
    }

    func getAverageEpisodeDuration() -> String {
        guard let seconds = average_episode_duration else { return "?" }
        return "\(seconds / 60) mins"
    }

    func getStudios() -> String {
        guard let studios = studios else { return "No studios found." }
        
        return studios.map{ $0.name }.joined(separator: ", ")
    }
}


struct AnimeSeason: Codable {
    var year: Int
    var season: Season
}

struct Studio: Codable, Equatable {
    var name: String
}

struct AnimeNodeSmall: Codable {
    var id: Int
    var title: String
    var main_picture: MainPicture
}

struct Broadcast: Codable {
    var day_of_the_week: String?
    var start_time: String?
}

struct Author: Codable {
    var node: AuthorDetail
    var role: String
}

struct AuthorDetail: Codable {
    var first_name: String?
    var last_name: String?
}

struct Publisher: Codable {
    var node: PublisherDetail
}

struct PublisherDetail: Codable {
    var name: String
}

struct Statistics: Codable {
    var status: Status?
    var num_list_users: Int
}

struct Status: Codable {
    var watching: String
    var completed: String
    var on_hold: String
    var dropped: String?
    var plan_to_watch: String
}

enum Ranking: String {
    case manga, novels, manhwa, manhua
}

enum Season: String, CaseIterable, Codable {
    case fall, summer, spring, winter
//    var id: Self { self }
    
    enum CodingKeys: String, CodingKey {
        case fall, summer, spring, winter
    }
}

enum AnimeType: String, CaseIterable, Codable {
    case anime, manga, novels, manhwa, manhua, oneshots, doujin
//    var id: Self { self } // forEach
    
}
