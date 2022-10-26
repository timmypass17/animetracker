//
//  HomeViewModel.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var selectedViewMode: ViewMode = .watching
    @Published var selectedSearchMode: SearchMode = .all
    @Published var animeData: [Anime] = Anime.sampleAnimes
    @Published var filterResults: [Anime] = []
    @Published var filterText = ""
    
    enum ViewMode: String, CaseIterable, Identifiable {
        case watching, completed, planning
        var id: Self { self } // forEach
    }

    enum SearchMode: String, CaseIterable, Identifiable {
        case all, anime, manga
        var id: Self { self } // forEach
    }

}
