//
//  SearchView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/25/22.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Picker("View Mode", selection: $homeViewModel.selectedSearchMode) {
                    ForEach(HomeViewModel.SearchMode.allCases) { mode in
                        Text(mode.rawValue.capitalized)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .bottom])
                
                Divider()
                
                ForEach($searchViewModel.searchResults, id: \.node.id) { $animeNode in
                    NavigationLink {
                        AnimeCellDetail(animeNode: $animeNode)
                    } label: {
                        AnimeCell(animeNode: $animeNode)
                    }
                    .buttonStyle(.plain)
//                    AnimeCell(anime: $animeNode.node)
                }
                .padding([.horizontal])
                
                Spacer()
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .searchable(text: $searchViewModel.searchText)
        .onSubmit(of: .search) {
            Task {
                try await searchViewModel.fetchAnimeByTitle(title: searchViewModel.searchText)
            }
        }
        .onReceive(searchViewModel.$searchText.debounce(for: 0.5, scheduler: RunLoop.main)
        ) { _ in
            // Debounce. Fetch api calls after 0.5 seconds of not typing.
            Task {
                print("searching...")
                try await searchViewModel.fetchAnimeByTitle(title: searchViewModel.searchText)
                print(searchViewModel.searchResults.count)
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
                .environmentObject(SearchViewModel())
        }
    }
}
