//
//  Anime.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import Foundation
import CloudKit


struct AnimeCollection: Codable {
    var data: [AnimeNode] = []
    var paging: Paging = Paging(next: "")
    var season: AnimeSeason?
    
    struct Paging: Codable {
        var next: String?
    }
    
    func seasonFormatted() -> String {
        guard let season = self.season?.season.rawValue.capitalized else { return "?" }
        guard let year =  self.season?.year else { return "?" }

        return "\(season) \(year)"
    }
}

struct AnimeNode: Codable {
    
    // put stuff in json tree here.
    private enum CodingKeys: String, CodingKey {
        case node
    }
    
    var node: Anime
    var record: CKRecord = CKRecord(recordType: "Anime") // not in json tree, so its not in enum. episodes_seen should be inside on cloudkit
    
    // unwrap record fields
    // computed property. doesnt store a value but provides getter and optional setter to retrieve and set other properties and values indirectly
    var episodes_seen: Int {
        get { record["episodes_seen"] as? Int ?? 0 }
        set { record["episodes_seen"] = newValue }
    }
}

struct Anime: Codable {
    var id: Int
    var title: String
    var main_picture: Poster
    var alternative_titles: AlternativeTitle
    var start_date: String?
    var end_date: String? // not in manga
    var synopsis: String
    var mean: Float?
    var rank: Int?
    var popularity: Int
    var num_list_users: Int
    var media_type: String
    var status: String
    var genres: [Genre]
    var num_episodes: Int?
    var start_season: AnimeSeason?
    var broadcast: Broadcast?
    var source: String?
    var average_episode_duration: Int?
    var rating: String?
    var related_anime: [RelatedNode]?
    var related_manga: [RelatedNode]?
    var recommendations: [RelatedNode]?
    var studios: [Studio]?
    
    /** manga only  */
    var num_volumes: Int?
    var num_chapters: Int?
    var authors: [Author]?
    var serialization: [Publisher]?
    
    var animeType: AnimeType?
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id, title, main_picture, alternative_titles, start_date, end_date, synopsis, mean, rank, popularity, num_list_users, media_type, status, genres, num_episodes, start_season, broadcast, source, average_episode_duration, rating, related_anime, related_manga, recommendations, studios, num_volumes, num_chapters, authors, serialization
    }
    
    init(id: Int = 0, title: String = "", main_picture: Poster = Poster(medium: "", large: ""), alternative_titles: AlternativeTitle = AlternativeTitle(synonyms: [], en: "", ja: ""), start_date: String? = nil, end_date: String? = nil, synopsis: String = "", mean: Float? = nil, rank: Int? = nil, popularity: Int = 0, num_list_users: Int = 0, media_type: String = "", status: String = "", genres: [Genre] = [], num_episodes: Int? = 0, start_season: AnimeSeason? = nil, broadcast: Broadcast? = nil, source: String? = nil, average_episode_duration: Int? = nil, rating: String? = nil, related_anime: [RelatedNode]? = nil, related_manga: [RelatedNode]? = nil, recommendations: [RelatedNode]? = nil, studios: [Studio]? = [], num_volumes: Int? = nil, num_chapters: Int? = nil, authors: [Author]? = nil, serialization: [Publisher]? = nil, animeType: AnimeType = .anime) {
        self.id = id
        self.title = title
        self.main_picture = main_picture
        self.alternative_titles = alternative_titles
        self.start_date = start_date
        self.end_date = end_date
        self.synopsis = synopsis
        self.mean = mean
        self.rank = rank
        self.popularity = popularity
        self.num_list_users = num_list_users
        self.media_type = media_type
        self.status = status
        self.genres = genres
        self.num_episodes = num_episodes
        self.start_season = start_season
        self.broadcast = broadcast
        self.source = source
        self.average_episode_duration = average_episode_duration
        self.rating = rating
        self.related_anime = related_anime
        self.related_manga = related_manga
        self.recommendations = recommendations
        self.studios = studios
        self.num_volumes = num_volumes
        self.num_chapters = num_chapters
        self.authors = authors
        self.serialization = serialization
        self.animeType = animeType
    }
}

extension Anime {
    func meanFormatted() -> String {
        guard let mean = mean else {
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
            return "TBA"
        }
        
        return "\(start_season.season.rawValue.capitalized) \(start_season.year)"
    }
    
    func numEpisodesFormatted() -> String {
        guard let animeType = animeType else {
            return "?"
        }
        
        switch animeType {
        case .anime:
            guard let num_episodes = num_episodes else { return "0" }
            return "\(num_episodes)"
        default:
            guard let num_chapters = num_chapters else { return "0" }
            return "\(num_chapters)"
        }
    }
    
    func episodeTypeFormatted() -> String {
        guard let animeType = animeType else {
            return "?"
        }
        
        switch animeType {
        case .all:
            return "?"
        case .anime:
            return "Episodes"
        default:
            return "Chapters"
        }
    }
    
    func cellLabel() -> String {
        switch animeType {
        case .anime:
            return "\(media_type.uppercased()) - \(numEpisodesFormatted()) \(episodeTypeFormatted())"
        default:
            return "\(media_type.capitalized) - Ch. \(numEpisodesFormatted())"
        }
    }
    
    func statusFormatted() -> String {
        return status.capitalized.replacingOccurrences(of: "_", with: " ")
    }
    
    func averageEpisodeDurationFormatted() -> String {
        guard let seconds = average_episode_duration else {
            return "?"
        }
        
        return "\(seconds / 60) mins"
    }
    
    func broadcastFormatted() -> String {
        guard status != "finished_airing" else { return "Finished Airing" }
        
        guard let broadcast = broadcast else { return "TBA" }
        guard let weekday = broadcast.day_of_the_week else { return "TBA" }
        guard let start_time = broadcast.start_time else { return "TBA" }
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = dateFormatter.date(from: "\(start_time)") // create date object
        
        dateFormatter.dateFormat = "H:mm a" // add am,pm
        
        if let date = date {
            let newDate = dateFormatter.string(from: date)
            return "\(weekday.capitalized), \(newDate) (JSP)"
        }
        
        return "TBA"
    }
    
    func studiosFormatted() -> String {
        guard let studios = studios else { return "No studios found." }
        
        return studios.map( { $0.name } ).joined(separator: ", ")
    }
    
    func airedDateFormatted() -> String {
        let start: String = convertAiredDate(date: start_date)
        let end: String = convertAiredDate(date: end_date)
        
        return "\(start ) to \(end)"
    }
    
    func convertAiredDate(date: String?) -> String {
        guard date != nil else { return "?" }
        
        // "2015-04-06" -> yyyy-MM-dd
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MM/dd/yyyy"
        
        if let start_date_formatted = dateFormatterGet.date(from: date!) {
            return dateFormatterPrint.string(from: start_date_formatted)
        } else {
            return "Error converting aired date"
        }
    }
    
    func titleFormatted() -> String {
        return alternative_titles.en != "" ? alternative_titles.en : title
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
    static let relatedAnime: RelatedNode = RelatedNode(node: AnimeNodeSmall(id: 1, title: "One Piece Movie", main_picture: Poster(medium: "https://api-cdn.myanimelist.net/images/anime/6/73245.jpg", large: "https://api-cdn.myanimelist.net/images/anime/6/73245.jpg")), relation_type_formatted: "Prequel")
    
    static let sampleData: [AnimeNode] =
    [
        AnimeNode(
            node: Anime(
                id: 21,
                title: "One Piece",
                main_picture: Poster(medium: "https://api-cdn.myanimelist.net/images/anime/6/73245.jpg", large: "https://api-cdn.myanimelist.net/images/anime/6/73245.jpg"),
                alternative_titles: AlternativeTitle(synonyms: ["Daiya no Ace: Second Season", "Ace of the Diamond: 2nd Season"], en: "One Piece", ja: "One Piece"),
                start_date: "2015-04-06",
                end_date: "2016-03-28",
                synopsis: "Gol D. Roger was known as the Pirate King, the strongest and most infamous being to have sailed the Grand Line. The capture and execution of Roger by the World Government brought a change throughout the world. His last words before his",
                mean: 8.68,
                rank: 58,
                popularity: 21,
                num_list_users: 2072905,
                media_type: "tv",
                status: "currently_airing",
                genres: [Genre(name: "Action"), Genre(name: "Adventure"), Genre(name: "Comedy")],
                num_episodes: 0,
                start_season: AnimeSeason(year: 1999, season: .fall),
                broadcast: Broadcast(day_of_the_week: "monday", start_time: "18:00"),
                source: "manga",
                average_episode_duration: 1440,
                rating: "pg_13",
                related_anime: [AnimeCollection.relatedAnime],
                related_manga: nil,
                recommendations: [],
                studios: [Studio(name: "Toei Animation")],
                //num_volumes, num_chapters, authors, serialization
                num_volumes: nil,
                num_chapters: nil,
                authors: nil,
                serialization: nil
            )
        ),
        AnimeNode(
            node: Anime(
                id: 2,
                title: "Berserk",
                main_picture: Poster(medium: "https://myanimelist.cdn-dena.com/images/manga/1/157931.jpg", large: "https://myanimelist.cdn-dena.com/images/manga/1/157931l.jpg"),
                alternative_titles: AlternativeTitle(synonyms: ["Berserk: The Prototype"], en: "Berserk", ja: "ベルセルク"),
                start_date: "1989-08-25",
                end_date: nil,
                synopsis: "Guts, a former mercenary now known as the \"Black Swordsman,\" is out for revenge. After a tumultuous childhood, he finally finds someone he respects and believes he can trust, only to have everything fall apart when this person takes away everything important to Guts for the purpose of fulfilling his own desires. Now marked for death, Guts becomes condemned to a fate in which he is relentlessly pursued by demonic beings.\n\nSetting out on a dreadful quest riddled with misfortune, Guts, armed with a massive sword and monstrous strength, will let nothing stop him, not even death itself, until he is finally able to take the head of the one who stripped him—and his loved one—of their humanity.\n\n[Written by MAL Rewrite]\n\nIncluded one-shot:\nVolume 14: Berserk: The Prototype",
                mean: 9.3,
                rank: 1,
                popularity: 7,
                num_list_users: 189296,
                media_type: "manga",
                status: "currently_publishing",
                genres: [Genre(name: "Action"), Genre(name: "Adventure"), Genre(name: "Fantasy")],
                num_episodes: nil,
                start_season: nil,
                broadcast: nil,
                source: nil,
                average_episode_duration: nil,
                rating: nil,
                related_anime: [],
                related_manga: [],
                recommendations: [],
                studios: nil,
                //num_volumes, num_chapters, authors, serialization
                num_volumes: 0,
                num_chapters: 0,
                authors: [Author(node: AuthorDetail(first_name: "Kentarou", last_name: "Miura"), role: "Story & Art")],
                serialization: [Publisher(node: PublisherDetail(name: "Young Animal"))]
            )
        )
    ]
}


struct Poster: Codable {
    var medium: String
    var large: String
}

struct Genre: Codable, Equatable {
    var name: String
}

struct AnimeSeason: Codable {
    var year: Int
    var season: Season
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

struct Broadcast: Codable {
    var day_of_the_week: String?
    var start_time: String?
}


extension Double {
    func reduceScale(to places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let truncated = Double(Int(newDecimal)) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal
    }
}

func formatNumber(_ n: Int) -> String {
    let num = abs(Double(n))
    let sign = (n < 0) ? "-" : ""
    
    switch num {
    case 1_000_000_000...:
        var formatted = num / 1_000_000_000
        formatted = formatted.reduceScale(to: 1)
        return "\(sign)\(formatted)B"
        
    case 1_000_000...:
        var formatted = num / 1_000_000
        formatted = formatted.reduceScale(to: 1)
        return "\(sign)\(formatted)M"
        
    case 1_000...:
        var formatted = num / 1_000
        formatted = formatted.reduceScale(to: 1)
        return "\(sign)\(formatted)K"
        
    case 0...:
        return "\(n)"
        
    default:
        return "\(sign)\(n)"
    }
}

protocol WeebItem {
    var id: Int { get }
    var title: String { get }
    var main_picture: Poster { get }
    var alternative_titles: AlternativeTitle { get }
    var start_date: String? { get }
    var end_date: String? { get }
    var synopsis: String { get }
    var mean: Float? { get }
    var rank: Int? { get }
    var popularity: Int { get }
    var num_list_users: Int { get }
    var media_type: String { get }
    var status: String { get }
    var genres: [Genre] { get }
    var num_episodes: Int { get }
    var start_season: AnimeSeason? { get }
    var broadcast: Broadcast? { get }
    var source: String? { get }
    var average_episode_duration: Int? { get }
    var rating: String? { get }
    var related_anime: [RelatedNode]? { get }
    var related_manga: [RelatedNode]? { get }
    var recommendations: [RelatedNode]? { get }
    var studios: [Studio] { get }
}
