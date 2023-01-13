//
//  SearchView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/25/22.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var animeViewModel: AnimeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SearchTabView()
                    .padding([.horizontal, .bottom])
                
                Divider()
                
                AnimeList(animeData: $animeViewModel.searchResults)
            }
        }
        .searchable(text: $animeViewModel.searchText)
        .onSubmit(of: .search) {
            Task {
                try await animeViewModel.fetchAnimesByTitle(title: animeViewModel.searchText)
            }
        }
        .onReceive(animeViewModel.$searchText.debounce(for: 0.3, scheduler: RunLoop.main)
        ) { _ in
            // Debounce. Fetch api calls after 0.5 seconds of not typing.
            Task {
                try await animeViewModel.fetchAnimesByTitle(title: animeViewModel.searchText)
            }
        }
        .navigationTitle("Search for Anime")
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchView()
                .environmentObject(AnimeViewModel())
//                .environmentObject(SearchViewModel())
        }
    }
}
