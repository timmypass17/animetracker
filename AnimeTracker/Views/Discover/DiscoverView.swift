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
                        DiscoverAnimeList(geometry: geometry)
                    default:
                        MangaList(geometry: geometry, mangaTypes: [.manga, .novels, .manhwa, .manhua, .oneshots, .doujin])
                    }
                }
            }
//            .toolbar {
//                ToolbarItem {
//                    Button(action: { discoverViewModel.isShowingSheet.toggle() }) {
//                        Image(systemName: "info.circle")
//                    }
//                }
//            }
            .sheet(isPresented: $discoverViewModel.isShowingSheet) {
                InfoView()
            }
            .searchable(
                text: $discoverViewModel.searchText,
                prompt: discoverViewModel.selectedAnimeType == .anime ? "Search Anime" : "Search Mangas, Novels, etc"
            ) {
                WatchList()
            }
            .autocorrectionDisabled(true)
            .onSubmit(of: .search) {
//                Task {
//                    if discoverViewModel.selectedAnimeType == .anime {
//                        discoverViewModel.searchResults = try await discoverViewModel.fetchAnimesByTitle(title: discoverViewModel.searchText).data
//                    } else {
//                        discoverViewModel.searchResults = try await discoverViewModel.fetchMangasByTitle(title: discoverViewModel.searchText).data
//                    }
//                }
            }
            .onReceive(discoverViewModel.$searchText.debounce(for: 0.3, scheduler: RunLoop.main)
            ) { _ in
                // Debounce. Fetch api calls after 0.5 seconds of not typing.
//                Task {
//                    if discoverViewModel.selectedAnimeType == .anime {
//                        discoverViewModel.searchResults = try await discoverViewModel.fetchAnimesByTitle(title: discoverViewModel.searchText).data
//                    } else {
//                        discoverViewModel.searchResults = try await discoverViewModel.fetchMangasByTitle(title: discoverViewModel.searchText).data
//                    }
//                }
            }
            .navigationTitle("Discover Anime")
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
