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
    var season: AnimeSeason?
}

struct AnimeNode: Codable {
    var node: Anime
    var record: AnimeProgress = AnimeProgress()
    
    // put stuff in json tree here.
    private enum CodingKeys: CodingKey {
        case node
    }
}

struct Anime: Codable {
    var id: Int
    var title: String?
    var main_picture: Poster?
    var alternative_titles: AlternativeTitle?
    var start_date: String?
    var end_date: String?
    var synopsis: String?
    var mean: Float?
    var rank: Int?
    var popularity: Int?
    var num_list_users: Int?
    var media_type: MediaType?
    var status: String? // TODO: use enum
    var genres: [Genre]?
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
//    var statistics: Statistics?
        
    // infer either anime, manga, novel, etc.. from media type (ex. 'tv' is an anime)
    var animeType: AnimeType {
        guard let media_type = media_type else { return .anime }
        
        switch media_type {
        case .tv, .ova, .ona, .movie, .special, .music:
            return .anime
        case .manga:
            return .manga
        case .light_novel, .novel:
            return .novels
        case .manhwa:
            return .manhwa
        case .manhua:
            return .manhua
        case .doujinshi:
            return .doujin
        case .one_shot:
            return .oneshots
        }
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id, title, main_picture, alternative_titles, start_date, end_date, synopsis, mean, rank, popularity, num_list_users, media_type, status, genres, num_episodes, start_season, broadcast, source, average_episode_duration, rating, related_anime, related_manga, recommendations, studios, num_volumes, num_chapters, authors, serialization
    }
}

/// Getters
extension Anime {
    
    func getMean() -> String {
        guard let mean = mean else { return "?" }
        return String(format: "%.2f", mean)
    }
    
    func getRank() -> String {
        guard let rank = rank else { return "?" }
        return String(rank)
    }
    
    func getRating() -> String {
        return rating ?? "?"
    }
    
    func getSeasonYear() -> String {
        guard let start_season = start_season else { return "?" }
        return "\(start_season.season.rawValue.capitalized) \(start_season.year)"
    }
    
    func getNumEpisodesOrChapters() -> Int {
        if let num_episodes = num_episodes { return num_episodes }
        if let num_chapters = num_chapters { return num_chapters }
        return 0
    }
    
    func getEpisodesOrChapters() -> String {
        return animeType == .anime ? "Episodes" : "Chapters"
    }
    
    func getStatus() -> String {
        guard let status = status else { return "?" }
        return status.capitalized.replacingOccurrences(of: "_", with: " ")
    }
    
    func getEpisodeMinutes() -> String {
        guard let seconds = average_episode_duration else { return "?" }
        return "\(seconds / 60) mins"
    }
    
    func getMediaType() -> String {
        return media_type?.rawValue ?? "?"
    }
    
    func getBroadcast() -> String {
        guard let broadcast = broadcast else { return getStatus() }
        guard let weekday = broadcast.day_of_the_week else { return getStatus() }
        guard let start_time = broadcast.start_time else { return getStatus() }
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = dateFormatter.date(from: "\(start_time)") // create date object
                
        if let date = date {
            let dateStr = dateFormatter.string(from: date)
            return "\(weekday.capitalized), \(dateStr) (JSP)"
        }
        
        return "TBA"
    }
    
    func getEpisodeOrChapter() -> String {
        return animeType == .anime ? "Episode" : "Chapter"
    }
        
    func getStudios() -> String {
        guard let studios = studios else { return "No studios found." }
        
        return studios.map( { $0.name } ).joined(separator: ", ")
    }
    
    func getAiringTime() -> String {
        
        func convertAiredDate(date: String?) -> String {
            guard date != nil else { return "?" }
            
            // "2015-04-06": yyyy-MM-dd
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            
            // "2015-04-06" -> "04/06/2015
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MM/dd/yyyy"
            
            if let start_date_formatted = dateFormatterGet.date(from: date!) {
                return dateFormatterPrint.string(from: start_date_formatted)
            } else {
                return "Error converting aired date"
            }
        }
        
        let start: String = convertAiredDate(date: start_date)
        let end: String = convertAiredDate(date: end_date)
        
        return "\(start) to \(end)"
    }
    
    func getTitle() -> String {
        if let title = title { return title }
        if let alternativeTitles = alternative_titles {
            if let englishTitle = alternativeTitles.en { return englishTitle }
            if let japanaeseTitle = alternativeTitles.ja { return japanaeseTitle }
            if let otherTitles = alternativeTitles.synonyms {
                if let other = otherTitles.first { return other }
            }
        }
        return ""
    }
    
    func getJapaneseTitle() -> String {
        if let japaneseTitle = alternative_titles?.ja { return japaneseTitle }
        return ""
    }
    
    func animeCellHeader() -> String {
        if animeType == .anime {
            return getSeasonYear()
        } else {
            if let media_type = media_type {
                return media_type.rawValue.capitalized
            }
        }
        return "?"
    }
    
    func getRatingFormatted() -> String {
        if let rating = rating {
            return rating.replacingOccurrences(of: "_", with: " ").capitalized
        }
        
        return "?"
    }
    
    func getSynopsis() -> String {
        guard let synopsis = synopsis else { return "?" }
        return synopsis
    }
    
    func getNumListUser() -> String {
        guard let num_list_users = num_list_users else { return "?" }
        return formatNumber(num_list_users)
    }
    
    func getNumChapters() -> String {
        guard let num_chapters = num_chapters else { return "?" }
        return String(num_chapters)
    }
    
    func getNumVolume() -> String {
        guard let num_volumes = num_volumes else { return "?" }
        return String(num_volumes)
    }
    
//    func getWatching() -> String {
//        return formatNumber(Int(statistics?.status?.watching ?? "0") ?? 0)
//    }
//
//    func getCompleted() -> String {
//        return formatNumber(Int(statistics?.status?.completed ?? "0") ?? 0)
//    }
//
//    func getOnHold() -> String {
//        return formatNumber(Int(statistics?.status?.on_hold ?? "0") ?? 0)
//    }
//
//    func getDropped() -> String {
//        return formatNumber(Int(statistics?.status?.dropped ?? "0") ?? 0)
//    }
//
//    func getPlanToWatch() -> String {
//        return formatNumber(Int(statistics?.status?.plan_to_watch ?? "0") ?? 0)
//    }
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
    var synonyms: [String]?
    var en: String?
    var ja: String?
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

enum Season: String, CaseIterable, Codable, Identifiable {
    case fall, summer, spring, winter
    var id: Self { self }
}

enum AnimeType: String, CaseIterable, Identifiable, Codable {
    case anime, manga, novels, manhwa, manhua, oneshots, doujin
    var id: Self { self } // forEach
}

enum MediaType: String, Codable {
    case tv, ova, ona, movie, special, music
    case manga, manhwa, manhua, one_shot, doujinshi
    case light_novel, novel // these are 2 different things (light novels are short, novels are long)
}

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
                media_type: .tv,
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
//                statistics: Statistics(status: Status(watching: "7799", completed: "35492", on_hold: "2802", dropped: "1242", plan_to_watch: "9859"), num_list_users: 57194)
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
                media_type: .manga,
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
//                statistics: Statistics(status: Status(watching: "7799", completed: "35492", on_hold: "2802", dropped: "1242", plan_to_watch: "9859"), num_list_users: 57194)
            )
        )
    ]
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
