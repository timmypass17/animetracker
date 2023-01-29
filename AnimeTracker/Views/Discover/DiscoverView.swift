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
//                                    
//                    DiscoverRow(categoryName: "Top Airing Anime", animeNodes: discoverViewModel.topAiringData, geometry: geometry)
//                        .padding(.top)
//                                    
//                    DiscoverRow(categoryName: "Top Upcoming Anime", animeNodes: discoverViewModel.topUpcomingData, geometry: geometry)
//                        .padding(.top)
//                    
                    DiscoverRow(animeNodes: discoverViewModel.fallData, season: .fall, year: discoverViewModel.fallYear, geometry: geometry)
                        .padding(.top)
                    
                    DiscoverRow(animeNodes: discoverViewModel.summerData, season: .summer, year: discoverViewModel.summerYear, geometry: geometry)
                        .padding(.top)
                    
                    DiscoverRow(animeNodes: discoverViewModel.springData, season: .spring, year: discoverViewModel.springYear, geometry: geometry)
                        .padding(.top)
                    
                    DiscoverRow(animeNodes: discoverViewModel.winterData, season: .winter, year: discoverViewModel.winterYear, geometry: geometry)
                        .padding(.top)
                }
            }
            .searchable(
                text: $animeViewModel.searchText,
                prompt: "Search Anime"
            ) {
                AnimeList(animeData: $animeViewModel.searchResults)
            }
    //        .searchable(text: $animeViewModel.searchText)
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
        .navigationTitle("Discover Animes")
        }
        .background(Color.ui.background)
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DiscoverView()
                .environmentObject(AnimeViewModel())
                .environmentObject(DiscoverViewModel())
        }
    }
}
