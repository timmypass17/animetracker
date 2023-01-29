//
//  Manga.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/28/23.
//

import Foundation

struct Manga: WeebItem, Codable {
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
    var num_episodes: Int
    var start_season: AnimeSeason?
    var broadcast: Broadcast?
    var source: String?
    var average_episode_duration: Int?
    var rating: String?
    var related_anime: [RelatedNode]?
    var related_manga: [RelatedNode]?
    var recommendations: [RelatedNode]?
    var studios: [Studio]
    
    /** manga only  */
    var num_volumes: Int
    var num_chapters: Int
    var authors: [Author]
    var serialization: [Publisher]
}

struct Author: Codable {
    var node: AuthorDetail
    var role: String
}

struct AuthorDetail: Codable {
    var first_name: String
    var last_name: String
}

struct Publisher: Codable {
    var node: PublisherDetail
}

struct PublisherDetail: Codable {
    var name: String
}
