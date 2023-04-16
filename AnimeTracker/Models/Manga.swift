//
//  Manga.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/11/23.
//

import Foundation

struct Manga: WeebItem, Codable {
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
    var num_volumes: Int?
    var num_chapters: Int?
    var related_manga: [RelatedItem]?
    var authors: [Author]?
    var serialization: [Publisher]?
    // var authors: []

    enum CodingKeys: String, CodingKey, CaseIterable {
        case id, title, main_picture, alternative_titles, start_date, end_date, synopsis, mean, rank, popularity, num_list_users, media_type, status, genres, num_volumes, num_chapters, related_manga, authors, serialization
    }
}

extension Manga {
    func getNumVolumes() -> Int {
        return num_volumes ?? 0
    }
    
    func getNumChapters() -> Int {
        return num_chapters ?? 0
    }
}
