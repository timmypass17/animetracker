//
//  DiscoverView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/25/22.
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var animeViewModel: AnimeViewModel
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 0) {
                    DiscoverTabView()
                        .padding([.horizontal, .bottom])
                    
                    Divider()
                    
                    switch discoverViewModel.selectedAnimeType {
                    case .anime:
                        DiscoverAnimeContent(geometry: geometry)
                    default:
                        MangaList(geometry: geometry, mangaTypes: [.manga, .novels, .manhwa, .manhua])
                    }
                    
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {}) {
                        Image(systemName: "info.circle")
                    }
                }
                
            }
            .searchable(
                text: $discoverViewModel.searchText,
                prompt: "Search Anime"
            ) {
                AnimeList(animeData: $discoverViewModel.searchResults)
            }
            .onSubmit(of: .search) {
                Task {
                    try await discoverViewModel.fetchAnimesByTitle(title: discoverViewModel.searchText)
                }
            }
            .onReceive(discoverViewModel.$searchText.debounce(for: 0.3, scheduler: RunLoop.main)
            ) { _ in
                // Debounce. Fetch api calls after 0.5 seconds of not typing.
                Task {
                    try await discoverViewModel.fetchAnimesByTitle(title: discoverViewModel.searchText)
                }
            }
            .navigationTitle("Discover Animes")
        }
        .background(Color.ui.background)
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DiscoverView()
                .environmentObject(AnimeViewModel(animeRepository: AnimeRepository()))
                .environmentObject(DiscoverViewModel(animeRepository: AnimeRepository()))
        }
    }
}
