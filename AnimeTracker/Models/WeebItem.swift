//
//  WeebItem.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/11/23.
//

import Foundation
import SwiftUI

// note: videos only available if searching by id
// optional: pictures, videos
// related anime/manga only available by id
protocol WeebItem: Codable {
    var id: Int { get }
    var title: String? { get }
    var main_picture: MainPicture? { get }
    var alternative_titles: AlternativeTitle? { get }
    var start_date: String? { get }
    var end_date: String? { get }
    var synopsis: String? { get }
    var mean: Float? { get }
    var rank: Int? { get }
    var popularity: Int? { get }
    var num_list_users: Int? { get }
    var media_type: MediaType? { get }
    var status: AiringStatus? { get }
    var genres: [Genre]? { get }
//    var rating: String? { get }
    var recommendations: [Recommendation]? { get }
    
    var progress: Progress? { get set}
}

enum WeebItemType: String, Codable {
    case anime, manga
}

struct MainPicture: Codable {
    var medium: String
    var large: String
}

struct AlternativeTitle: Codable {
    var synonyms: [String]?
    var en: String?
    var ja: String?
}

enum MediaType: String, Codable {
    case tv, ova, ona, movie, special, music
    case manga, manhwa, manhua, one_shot, doujinshi, light_novel, novel // light novels are short, novels are long
}

enum AiringStatus: String, Codable {
    case currently_airing, finished_airing, not_yet_aired   // anime
    case currently_publishing, on_hiatus, finished          // manga
    case other
}

struct Genre: Codable, Equatable {
    var name: String
}


struct Recommendation: Codable {
    let node: RecommendationNode
    let numRecommendations: Int?

    private enum CodingKeys: String, CodingKey {
        case node, numRecommendations = "num_recommendations"
    }
}

struct RecommendationNode: Codable {
    let id: Int
    let title: String
    let mainPicture: MainPicture

    private enum CodingKeys: String, CodingKey {
        case id, title, mainPicture = "main_picture"
    }
}

struct RelatedItem: Codable {
    let node: RecommendationNode
    let relation_type_formatted: String?
}

// MARK: Getters
extension WeebItem {
//    case tv, ova, ona, movie, special, music
//    case manga, manhwa, manhua, one_shot, doujinshi, light_novel, novel // light novels are short, novels are long
    
    func getWeebItemType() -> WeebItemType {
        switch media_type {
        case .tv, .ova, .ona, .movie, .special, .music:
            return .anime
        default:
            return .manga
        }

    }
    
    func getTitle() -> String {
        if let title = title { return title }
        if let alternativeTitles = alternative_titles {
            if let englishTitle = alternativeTitles.en { return englishTitle }
            if let otherTitles = alternativeTitles.synonyms {
                if let other = otherTitles.first { return other }
            }
            if let japanaeseTitle = alternativeTitles.ja { return japanaeseTitle }
        }
        return "No title yet."
    }

    func getPosterUrl(size: PosterSize) -> String? {
        guard let main_picture = main_picture else { return nil }
        switch size {
        case .medium:
            return main_picture.medium
        case .large:
            return main_picture.large
        }
    }

    func getJapaneseTitle() -> String? {
        return alternative_titles?.ja ?? nil
    }

    func getStartDate() -> String {
        guard let start_date = start_date else { return "No start date" }

        // "2015-04-06": yyyy-MM-dd
        let dateFormatterIn = DateFormatter()
        dateFormatterIn.dateFormat = "yyyy-MM-dd"

        // "2015-04-06" -> "04/06/2015
        let dateFormatterOut = DateFormatter()
        dateFormatterOut.dateFormat = "MM/dd/yyyy"

        if let start_date_formatted = dateFormatterIn.date(from: start_date) {
            return dateFormatterOut.string(from: start_date_formatted)
        }

        return "No start date"
    }
    
    func getStartSeasonAndYear() -> String {
        guard let start_date = start_date else { return "No start date" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: start_date) {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            
            var season = ""
            switch month {
            case 12, 1, 2:
                season = "Winter"
            case 3, 4, 5:
                season = "Spring"
            case 6, 7, 8:
                season = "Summer"
            case 9, 10, 11:
                season = "Fall"
            default:
                break
            }
            
            return "\(season) \(year)"// Output: "Spring 2015"
        }
        return "No start date"
    }

    func getEndDate() -> String? {
        guard let end_date = end_date else { return nil }

        // "2015-04-06": yyyy-MM-dd
        let dateFormatterIn = DateFormatter()
        dateFormatterIn.dateFormat = "yyyy-MM-dd"

        // "2015-04-06" -> "04/06/2015
        let dateFormatterOut = DateFormatter()
        dateFormatterOut.dateFormat = "MM/dd/yyyy"

        if let start_date_formatted = dateFormatterIn.date(from: end_date) {
            return dateFormatterOut.string(from: start_date_formatted)
        }

        return nil
    }

    func getSynopsis() -> String {
        return synopsis ?? "No synopsis yet."
    }

    func getMean() -> String {
        guard let mean = mean else { return "0" }
        return String(format: "%.2f", mean)
    }

    func getRank() -> String {
        guard let rank = rank else { return "0" }
        return String(rank)
    }

    func getPopularity() -> String {
        guard let popularity = popularity else { return "0" }
        return String(popularity)
    }

    func getNumListUser() -> String {
        guard let num_list_users = num_list_users else { return "0" }
        return formatNumber(num_list_users)
    }

    func getMediaType() -> String {
        return media_type?.rawValue ?? "Media not found"
    }

    func getStatus() -> String {
        guard let status = status else { return AiringStatus.other.rawValue }
        return status.rawValue.capitalized.replacingOccurrences(of: "_", with: " ")
    }

    func getGenres() -> [String] {
        guard let genres = genres else { return [] }
        return genres.map { $0.name }
    }

    func getAiringStatusColor() -> Color {
        switch status {
        case .currently_airing, .on_hiatus, .currently_publishing:
            return .yellow
        case .finished_airing, .finished:
            return .green
        default:
            return .red
            
        }
    }
}

// MARK: Sample anime and manga data

struct SampleData {
    static let sampleData: [WeebItem] =
    [
        Anime(
            id: 21,
            title: "One Piece",
            main_picture: MainPicture(medium: "https://api-cdn.myanimelist.net/images/anime/6/73245.jpg", large: "https://api-cdn.myanimelist.net/images/anime/6/73245.jpg"),
            alternative_titles: AlternativeTitle(synonyms: ["Daiya no Ace: Second Season", "Ace of the Diamond: 2nd Season"], en: "One Piece", ja: "One Piece"),
            start_date: "2015-04-06",
            end_date: "2016-03-28",
            synopsis: "Gol D. Roger was known as the Pirate King, the strongest and most infamous being to have sailed the Grand Line. The capture and execution of Roger by the World Government brought a change throughout the world. His last words before his",
            mean: 8.68,
            rank: 58,
            popularity: 21,
            num_list_users: 2072905,
            media_type: .tv,
            status: .currently_airing,
            genres: [Genre(name: "Action"), Genre(name: "Adventure"), Genre(name: "Comedy")],
            recommendations: [],
            rating: "pg_13",
            num_episodes: 0,
            start_season: AnimeSeason(year: 1999, season: .fall),
            broadcast: Broadcast(day_of_the_week: "monday", start_time: "18:00"),
            source: "manga",
            average_episode_duration: 1440,
            related_anime: [],
            studios: [Studio(name: "Toei Animation")]
        ),
        Manga(
            id: 2,
            title: "Berserk",
            main_picture: MainPicture(
                medium: "https://api-cdn.myanimelist.net/images/manga/1/157897.jpg",
                large: "https://api-cdn.myanimelist.net/images/manga/1/157897l.jpg"),
            alternative_titles: AlternativeTitle(
                synonyms: [
                    "Berserk: The Prototype"
                ],
                en: "Verserk",
                ja: "ベルセルク"),
            start_date: "1989-08-25",
            end_date: nil,
            synopsis: "Guts, a former mercenary now known as the \"Black Swordsman,\" is out for revenge. After a tumultuous childhood, he finally finds someone he respects and believes he can trust, only to have everything fall apart when this person takes away everything important to Guts for the purpose of fulfilling his own desires. Now marked for death, Guts becomes condemned to a fate in which he is relentlessly pursued by demonic beings.\n\nSetting out on a dreadful quest riddled with misfortune, Guts, armed with a massive sword and monstrous strength, will let nothing stop him, not even death itself, until he is finally able to take the head of the one who stripped him—and his loved one—of their humanity.\n\n[Written by MAL Rewrite]\n\nIncluded one-shot:\nVolume 14: Berserk: The Prototype",
            mean: 9.47,
            rank: 1,
            popularity: 2,
            num_list_users: 618480,
            media_type: .manga,
            status: .currently_publishing,
            genres: [Genre(name: "Action"), Genre(name: "Adventure"), Genre(name: "Award Winning"), Genre(name: "Drama")],
            recommendations: [Recommendation(node: RecommendationNode(id: 583, title: "Claymore", mainPicture: MainPicture(medium: "https://api-cdn.myanimelist.net/images/manga/2/255378.jpg", large: "https://api-cdn.myanimelist.net/images/manga/2/255378l.jpg")), numRecommendations: 44)],
            progress: nil,
            num_volumes: 0,
            num_chapters: 0,
            related_manga: [RelatedItem(node: RecommendationNode(id: 92299, title: "Berserk: Sinen no Kami 2", mainPicture: MainPicture(medium: "https://api-cdn.myanimelist.net/images/manga/1/162254.jpg", large: "https://api-cdn.myanimelist.net/images/manga/1/162254l.jpg")), relation_type_formatted: "Other")],
            authors: [],
            serialization: [Publisher(node: PublisherDetail(name: "Young Animal"))])
    ]
}
