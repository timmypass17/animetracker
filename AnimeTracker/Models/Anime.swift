//
//  Anime.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import Foundation

struct Anime {
    var id: String
    var title: String
    var genre: [String]
    var posterUrl: String
    var episodes: String
}

extension Anime {
    static let url = "https://cdn11.bigcommerce.com/s-b72t4x/images/stencil/1280x1280/products/11169/20874/24_1075_Naruto_Group__97803.1624823918.jpg?c=2"
    static let sampleAnimes = [
        Anime(id: "1", title: "Naruto: Shippuden", genre: ["Action", "Shounen"], posterUrl: url, episodes: "456"),
        Anime(id: "2", title: "One Piece", genre: ["Adventure", "Comedy"], posterUrl: url, episodes: "987"),
        Anime(id: "3", title: "Bleach", genre: ["Shounen"], posterUrl: url, episodes: "345"),
        Anime(id: "4", title: "One Punch Man", genre: ["Comedy"], posterUrl: url, episodes: "46"),
        Anime(id: "5", title: "Chainsaw Man", genre: ["Action"], posterUrl: url, episodes: "24"),
    ]
}
