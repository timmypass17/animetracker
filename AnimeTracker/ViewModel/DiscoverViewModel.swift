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
    @Published var fallData = AnimeCollection()
    @Published var summerData = AnimeCollection()
    @Published var springData = AnimeCollection()
    @Published var winterData = AnimeCollection()
    
    @Published var fallDataPrev = AnimeCollection()
    @Published var summerDataPrev = AnimeCollection()
    @Published var springDataPrev = AnimeCollection()
    @Published var winterDataPrev = AnimeCollection()

    
    @Published var searchResults: [AnimeNode] = []
    
    @Published var mangaData = AnimeCollection()
    @Published var novelData = AnimeCollection()
    @Published var manhwaData = AnimeCollection()
    @Published var manhuaData = AnimeCollection()


    @Published var searchText = ""
    @Published var selectedAnimeType: AnimeType = .anime
    
    private var cancellables = Set<AnyCancellable>()
    var recentSeasons: [(Season, Int)] = []

    init(animeRepository: AnimeRepository) {
        self.animeRepository = animeRepository
        recentSeasons = getRecentSeasonYear()
        
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
        
        self.animeRepository.$fallDataPrev
            .assign(to: \.fallDataPrev, on: self)
            .store(in: &cancellables)
        
        self.animeRepository.$summerDataPrev
            .assign(to: \.summerDataPrev, on: self)
            .store(in: &cancellables)
        
        self.animeRepository.$springDataPrev
            .assign(to: \.springDataPrev, on: self)
            .store(in: &cancellables)
        
        self.animeRepository.$winterDataPrev
            .assign(to: \.winterDataPrev, on: self)
            .store(in: &cancellables)
        
        self.animeRepository.$searchResults
            .assign(to: \.searchResults, on: self)
            .store(in: &cancellables)
        
        self.animeRepository.$mangaData
            .assign(to: \.mangaData, on: self)
            .store(in: &cancellables)
        
        self.animeRepository.$novelData
            .assign(to: \.novelData, on: self)
            .store(in: &cancellables)
        
        self.animeRepository.$manhwaData
            .assign(to: \.manhwaData, on: self)
            .store(in: &cancellables)
        
        self.animeRepository.$manhuaData
            .assign(to: \.manhuaData, on: self)
            .store(in: &cancellables)
    }
    
    func fetchAnimesBySeason(season: Season, year: Int) async throws -> AnimeCollection {
        return try await animeRepository.fetchAnimesBySeason(season: season, year: year)
    }
    
    func fetchMangaByID(id: Int) async throws -> AnimeNode {
        return try await animeRepository.fetchMangaByID(id: id)
    }
    
    func fetchAnimesByTitle(title: String, limit: Int = 15) async throws {
        try await animeRepository.fetchAnimesByTitle(title: title, limit: limit)
    }
    
    func loadMore(animeCollection: AnimeCollection) async throws {
        guard let season = animeCollection.season else { return }
        try await animeRepository.loadMore(season: season.season, year: season.year)
    }
    
    func loadMoreManga(page: Int, animeType: AnimeType) async throws -> AnimeCollection {
        return try await animeRepository.fetchMangas(page: page, animeType: animeType)
    }
}

extension DiscoverViewModel {
    func getRecentSeasonYear() -> [(Season, Int)] {
        // swift's default mod doesnt work well with negatives
        func mod(x: Int, m: Int) -> Int {
            return (x % m + m) % m
        }
        
        var res: [(Season, Int)] = []
        
        var date = Date()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss Z" // 2023-02-05 00:39:33 +0000
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMMM yyyy"
        
        if let date = dateFormatterGet.date(from: date.description) {
            let dateParts = dateFormatterPrint.string(from: date).components(separatedBy: " ")
            let seasons: [Season] = Season.allCases
            let month = dateParts[0]
            var year = Int(dateParts[1])!
            var index: Int
            
            if ["January", "February", "March"].contains(month) {
                index = 0
            }
            else if ["April", "May", "June"].contains(month) {
                index = 1
            }
            else if ["July", "August", "September"].contains(month) {
                index = 2
            }
            else {
                index = 3
            }
            
            while res.count != 4 {
                res.append((seasons[mod(x: index, m: 4)], year))
                
                // previous year
                if index - 1 < 0 {
                    year -= 1
                }
                        
                index = mod(x: index - 1, m: 4)
            }
            
            return res
        }
        
        return []
    }
}

