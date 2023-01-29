//
//  DiscoverViewModel.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/13/23.
//

import SwiftUI
import Combine

@MainActor
class DiscoverViewModel: ObservableObject {
    @Published var animeRepository: AnimeRepository
    @Published var fallData: [AnimeNode] = []
    @Published var summerData: [AnimeNode] = []
    @Published var springData: [AnimeNode] = []
    @Published var winterData: [AnimeNode] = []
    @Published var searchResults: [AnimeNode] = []
    @Published var searchText = ""
    
    var fallYear = 2022
    var summerYear = 2022
    var springYear = 2022
    var winterYear = 2022
    
    private var cancellables = Set<AnyCancellable>()

    init(animeRepository: AnimeRepository) {
        self.animeRepository = animeRepository
        
        // fall data listen to changes in repository's fall data
        self.animeRepository.$fallData
            .assign(to: \.fallData, on: self)
            .store(in: &cancellables)
        
        self.animeRepository.$summerData
            .assign(to: \.summerData, on: self)
            .store(in: &cancellables)
        
        self.animeRepository.$springData
            .assign(to: \.springData, on: self)
            .store(in: &cancellables)
        
        self.animeRepository.$winterData
            .assign(to: \.winterData, on: self)
            .store(in: &cancellables)
        
        self.animeRepository.$searchResults
            .assign(to: \.searchResults, on: self)
            .store(in: &cancellables)
    }
    
    func fetchAnimesByTitle(title: String, limit: Int = 15) async throws {
        try await animeRepository.fetchAnimesByTitle(title: title, limit: limit)
    }
}

enum Ranking: String {
    case all, airing, upcoming, bypopularity
}

enum Season: String {
    case winter, spring, summer, fall
}
