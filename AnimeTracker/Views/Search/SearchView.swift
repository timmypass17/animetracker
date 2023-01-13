//
//  SearchView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/25/22.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SearchTabView()
                    .padding([.horizontal, .bottom])
                
                Divider()
                
                AnimeList(animeData: $homeViewModel.searchResults)
            }
        }
        .searchable(text: $homeViewModel.searchText)
        .onSubmit(of: .search) {
            Task {
                try await homeViewModel.fetchAnimesByTitle(title: homeViewModel.searchText)
            }
        }
        .onReceive(homeViewModel.$searchText.debounce(for: 0.3, scheduler: RunLoop.main)
        ) { _ in
            // Debounce. Fetch api calls after 0.5 seconds of not typing.
            Task {
                try await homeViewModel.fetchAnimesByTitle(title: homeViewModel.searchText)
            }
        }
        .navigationTitle("Search for Anime")
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchView()
                .environmentObject(HomeViewModel())
//                .environmentObject(SearchViewModel())
        }
    }
}
