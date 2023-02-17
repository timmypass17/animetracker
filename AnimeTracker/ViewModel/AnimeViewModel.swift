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
    @Published var animeRepository: AnimeRepository // share with other viewmodel, so create repo in main file, and pass into init()
    @Published var animeData: [AnimeNode] = []
    @Published var selectedAnimeData: [AnimeNode] = []
    
    @Published var filterResults: [AnimeNode] = []
    @Published var selectedViewMode: ViewMode = .all
    @Published var selectedAnimeType: AnimeType = .anime
    @Published var selectedSort: SortBy = .last_modified
    @Published var filterText = ""

    let TAG = "[AnimeViewModel]" // for debugging
    private var cancellables = Set<AnyCancellable>()
    
//    @Published var appState: AppState
    @Published var showErrorAlert = false
    @Published var showSucessAlert = false

    
    // request api call only once. Every "addition" is done locally, abstracted from user
    init(animeRepository: AnimeRepository) {
        self.animeRepository = animeRepository
//        self.appState = appState
        
        // subscribe to changes in repository. Connect publisher to another publisher
        self.animeRepository.$animeData
            .assign(to: \.animeData, on: self)
            .store(in: &cancellables)
        
        // selectedAnimeData subscribe to changes in animeData?
        $animeData
            .assign(to: \.selectedAnimeData, on: self)
            .store(in: &cancellables)
    }
    
    func fetchAnimeByID(id: Int) async throws -> AnimeNode {
        try await animeRepository.fetchAnime(animeID: id)
    }
    
    func addAnime(animeNode: AnimeNode) async {
        await animeRepository.saveAnime(animeNode: animeNode)
    }
    
    func deleteAnime(animeNode: AnimeNode) async {
        await animeRepository.deleteAnime(animeNode: animeNode)
    }
    
    func filterDataByTitle(query: String) {
        filterResults = animeRepository.animeData.filter { $0.node.getTitle().lowercased().contains(query.lowercased()) }
    }
    
    func applySort() {
        sortByMode()
        sortBySorting()
        
        func sortByMode() {
            switch selectedViewMode {
            case .all:
                selectedAnimeData = animeData
            case .in_progress:
                // Get animes between range 1 to num_episodes - 1
                var temp: [AnimeNode] = []
                
                for animeNode in animeData {
                    // is anime
                    if animeNode.node.animeType == .anime {
                        // has num episodes
                        if let numEpisodes = animeNode.node.num_episodes {
                            if numEpisodes == 0 {
                                temp.append(animeNode)
                            }
                            else if 0 < animeNode.episodes_seen && animeNode.episodes_seen < numEpisodes {
                                temp.append(animeNode)
                            }
                        }
                    } else { // is manga
                        if let numChapters = animeNode.node.num_chapters {
                            if numChapters == 0 {
                                temp.append(animeNode)
                            }
                            else if 0 < animeNode.episodes_seen && animeNode.episodes_seen < numChapters {
                                temp.append(animeNode)
                            }
                        }
                    }
                }
                
                selectedAnimeData = temp
                
            case .finished:
                selectedAnimeData = animeData.filter { ($0.record["episodes_seen"] as? Int ?? 0) == $0.node.num_episodes}
            case .not_started:
                selectedAnimeData = animeData.filter { $0.record["episodes_seen"] as? Int == 0 }
            }
        }
        
        func sortBySorting() {
            switch selectedSort {
            case .alphabetical:
                selectedAnimeData = selectedAnimeData.sorted { $0.node.getTitle() < $1.node.getTitle() }
            case .newest:
                selectedAnimeData = selectedAnimeData.sorted { $0.node.start_season?.year ?? 9999 > $1.node.start_season?.year ?? 9999 }
            case .date_created:
                selectedAnimeData = selectedAnimeData.sorted { $0.record.creationDate! > $1.record.creationDate! } // most recent on top
            case .last_modified:
                selectedAnimeData = selectedAnimeData.sorted { $0.record.modificationDate! > $1.record.modificationDate! }
            }
        }
    }

}

enum ViewMode: String, CaseIterable, Identifiable {
    case all, not_started, in_progress, finished
    var id: Self { self } // forEach
}

enum AnimeType: String, CaseIterable, Identifiable, Codable {
    case anime, manga, novels, manhwa, manhua, oneshots, doujin
    var id: Self { self } // forEach
}

enum FetchError: Error {
    case badRequest
    case badJson
    case badURL
}

enum Tab {
    case list
    case search
    case chart
}

enum SortBy: String, CaseIterable, Identifiable {
    case alphabetical
    case newest
    case date_created = "Date Created"
    case last_modified = "Last Modified"
    var id: Self { self }
}
