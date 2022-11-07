//
//  SearchViewModel.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/26/22.
//

import Foundation

enum FetchError: Error {
    case badRequest
    case badJson
}

class SearchViewModel: ObservableObject {
    @Published var searchResults: [AnimeNode] = []
    @Published var searchText = ""
    
    // https://api.myanimelist.net/v2/anime?q=one&fields=num_episodes
    let baseUrl = "https://api.myanimelist.net/v2"
    let apiKey = "e7bc56aa1b0ea0afe3299d889922e5b8"
    
    func fetchAnimeByTitle(title: String) async throws {
        print("[SearchViewModel] fetchAnime(\"\(title)\")")
        let titleFormatted = title.replacingOccurrences(of: " ", with: "_")
        
        let fieldValue = "num_episodes,genres,mean,rank,start_season,synopsis,studios,status,average_episode_duration,media_type"
        guard let url = URL(string: "\(baseUrl)/anime?q=\(titleFormatted)&fields=\(fieldValue)") else { return }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-MAL-CLIENT-ID")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FetchError.badRequest
        }
        Task { @MainActor in
            self.searchResults = try JSONDecoder().decode(AnimeCollection.self, from: data).data
        }
    }
}
