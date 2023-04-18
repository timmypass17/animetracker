//
//  AnimeViewModel.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import Foundation
import CloudKit
import Combine


@MainActor // to automatically dispatch UI updates on the main queue. Same as doing DispatchQueue.main.async{}
class AnimeViewModel: ObservableObject {
    @Published var userAnimeMangaList: [WeebItem] = []
    @Published var selectedAnimeData: [WeebItem] = []  // filtered version of anime data
    @Published var filterResults: [WeebItem] = []
    @Published var selectedViewMode: ViewMode = .all
    @Published var selectedSort: SortBy = .last_modified
    @Published var filterText = ""
    @Published var showErrorAlert = false
    
    var animeRepository: AnimeRepository // share with other viewmodel, so create repo in main file, and pass into init()
    var appState: AppState
    private var cancellables = Set<AnyCancellable>()
    let TAG = "[AnimeViewModel]"
    
    init(animeRepository: AnimeRepository, appState: AppState) {
        self.animeRepository = animeRepository
        self.appState = appState
        // subscribe to changes in repository. Connects publisher to another publisher. modifying userAnimeList updates animeData
        self.animeRepository.$animeData
            .assign(to: \.userAnimeMangaList, on: self)
            .store(in: &cancellables)
        
        // selectedAnimeData subscribe to changes in animeData?
        $userAnimeMangaList
            .assign(to: \.selectedAnimeData, on: self)
            .store(in: &cancellables)
    }
    
    func loadUserAnimeList() async {
        await animeRepository.loadUserAnimeList()
    }
    
    // TODO: Maybe make this return Result or optional, instead of default object.
    func fetchAnime(id: Int) async -> Anime {
        let result = await animeRepository.fetchAnime(animeID: id)
        switch result {
        case .success(let animeNode):
            print("Successfully got anime")
            return animeNode
        case .failure(_):
            print("Failed to get anime")
            return Anime(id: 0)
        }
    }
    
    // TODO: Should return optional. Is misleading to return default object
    func fetchMangaByID(id: Int) async -> Manga? {
        let result = await animeRepository.fetchManga(mangaID: id)
        switch result {
        case .success(let animeNode):
            print("Successfully got manga")
            return animeNode
        case .failure(_):
            print("Failed to get manga")
            return nil
        }
    }
    
    enum MALApiError: Error {
        case missingItem
    }

    func saveProgress(item: WeebItem, seen: Int) async -> WeebItem? {
        let result = await animeRepository.save(item: item, seen: seen)
        switch result {
        case .success(let record):
            // Update existing item
            if let index = userAnimeMangaList.firstIndex(where: { $0.id == item .id }) {
                userAnimeMangaList[index].progress = Progress(record: record)
                return userAnimeMangaList[index]
            }
            
            // Add item locally
            if var anime = item as? Anime {
                anime.progress = Progress(record: record)
                userAnimeMangaList.append(anime)
                return anime
            }
            else if var manga = item as? Manga {
                manga.progress = Progress(record: record)
                userAnimeMangaList.append(manga)
                return manga
            }
            return nil
        case .failure(let error):
            // Show iCloud error alert (e.g. User needs to relog iCloud password, should be rare)
            
            appState.activeAlert = .iCloudNotLoggedIn
            appState.showAlert = true
            return nil
        }
    }

//    func deleteAnime(animeNode: AnimeNode) async {
//        await animeRepository.deleteAnime(animeNode: animeNode)
//    }
//
//    func filterDataByTitle(query: String) {
//        filterResults = animeRepository.animeData.filter { $0.node.getTitle().lowercased().contains(query.lowercased()) }
//    }
    
}

extension AnimeViewModel {
//    func applySort() {
//        sortByMode()
//        sortBySorting()
//        
//        func sortByMode() {
//            switch selectedViewMode {
//            case .all:
//                selectedAnimeData = userAnimeList
//            case .in_progress:
//                selectedAnimeData = animeData.filter {
//                    var n = $0.node.getNumEpisodesOrChapters()
//                    if n == 0 { n = Int.max } // 0 episodes means series is ongoing
//                    return 1..<n ~= $0.record.seen
//                }
//            case .finished:
//                selectedAnimeData = animeData.filter { ($0.record.seen) == $0.node.getNumEpisodesOrChapters() && ($0.record.seen) != 0 }
//            case .not_started:
//                selectedAnimeData = animeData.filter { $0.record.seen == 0 }
//            }
//        }
//        
//        func sortBySorting() {
//            switch selectedSort {
//            case .alphabetical:
//                selectedAnimeData = selectedAnimeData.sorted { $0.node.getTitle() < $1.node.getTitle() }
//            case .newest:
//                selectedAnimeData = selectedAnimeData.sorted { $0.node.start_season?.year ?? Int.max > $1.node.start_season?.year ?? Int.max }
//            case .date_created:
//                selectedAnimeData = selectedAnimeData.sorted { $0.record.creationDate > $1.record.creationDate }
//            case .last_modified:
//                selectedAnimeData = selectedAnimeData.sorted { $0.record.modificationDate > $1.record.modificationDate }
//            }
//        }
//    }
}

enum ViewMode: String, CaseIterable, Identifiable {
    case all, not_started, in_progress, finished
    var id: Self { self } // forEach
}


enum SortBy: String, CaseIterable, Identifiable {
    case alphabetical
    case newest
    case date_created = "Date Created"
    case last_modified = "Last Modified"
    var id: Self { self }
}
