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
    @Published var searchResults: [WeebItem] = []
    @Published var topAiringAnimes: [Anime] = []
    @Published var popularMangas = [Manga]()
    @Published var searchText = ""
    @Published var selectedAnimeType: AnimeType = .anime
    @Published var isShowingSheet = false
    
    private var cancellables = Set<AnyCancellable>()
    var recentSeasons: [(Season, Int)] = []

    init(animeRepository: AnimeRepository) {
        self.animeRepository = animeRepository
        recentSeasons = getRecentSeasonYear()
        
//        self.animeRepository.$searchResults
//            .assign(to: \.searchResults, on: self)
//            .store(in: &cancellables)
        
        Task {
            var airingAnimes = await fetchTopAiringAnimes()
            while airingAnimes.count > 5 {
                airingAnimes.removeLast()
            }
            self.topAiringAnimes = airingAnimes
//            
            var mangas = try await fetchPopularMangas()
            while mangas.count > 5 {
                mangas.removeLast()
            }
            self.popularMangas = mangas
        }
    }
    
//    // TODO: Should return optional. Is misleading to return default object
//    func fetchMangaByID(id: Int) async -> Manga? {
//        let result = await animeRepository.fetchManga(mangaID: id)
//        switch result {
//        case .success(let animeNode):
//            print("Successfully got manga")
//            return animeNode
//        case .failure(_):
//            print("Failed to get manga")
//            return nil
//        }
//    }
    
    
    func fetchAnimesByTitle(title: String) async -> [Anime] {
        let result = await animeRepository.fetchAnimes(title: title)
        switch result {
        case .success(let animeCollection):
            return animeCollection.data.map { $0.node }
        case .failure(_):
            return []
        }
    }
    
    func fetchMangasByTitle(title: String, limit: Int = 15) async -> [Manga] {
        let result = await animeRepository.fetchMangas(title: title)
        switch result {
        case .success(let mangaCollection):
            return mangaCollection.data.map { $0.node }
        case .failure(_):
            return []
        }
    }
    
    func fetchTopAiringAnimes(season: Season = .fall, year: Int = 0, animeType: AnimeType = .anime, page: Int = 0) async -> [Anime] {
        let result = await animeRepository.fetchTopAiringAnimes(page: page)
        switch result {
        case .success(let animeCollection):
            return animeCollection.data.map { $0.node }
        case .failure(_):
            return []
        }
    }
    
    func fetchPopularMangas(season: Season = .fall, year: Int = 0, animeType: AnimeType = .anime, page: Int = 0) async throws -> [Manga] {
        let result = await animeRepository.fetchPopularMangas(page: page)
        switch result {
        case .success(let mangaCollection):
            return mangaCollection.data.map { $0.node }
        case .failure(_):
            return []
        }
    }
    
    func loadMoreAnimes(season: Season, year: Int, animeType: AnimeType = .anime, page: Int) async -> [Anime] {
        let result = await animeRepository.fetchAnimes(season: season, year: year, page: page)
        switch result {
        case .success(let animeCollection):
            return animeCollection.data.map { $0.node }
        case .failure(_):
            return []
        }
    }
    
    func loadMoreMangas(season: Season = .fall, year: Int = 0, animeType: AnimeType, page: Int) async -> [Manga] {
        let result = await animeRepository.fetchMangas(animeType: animeType, page: page)
        switch result {
        case .success(let mangaCollection):
            return mangaCollection.data.map { $0.node }
        case .failure(_):
            // TODO: change func to return either optional or Result. Returning default object hides underlying issue.
            return []
        }
    }

}

extension DiscoverViewModel {
    func getRecentSeasonYear() -> [(Season, Int)] {
        // swift's default mod doesnt work well with negatives
        func mod(x: Int, m: Int) -> Int {
            return (x % m + m) % m
        }
        
        var res: [(Season, Int)] = []
        
        let date = Date()
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

