//
//  SearchViewModel.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/26/22.
//

import Foundation

class SearchViewModel: ObservableObject {
    
    @Published var searchResults: [Anime] = []
    @Published var searchText = ""
    
    
}
