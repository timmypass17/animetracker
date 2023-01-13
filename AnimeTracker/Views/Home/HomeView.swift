//
//  HomeView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/23/22.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HomeTabView()
                    .padding([.horizontal, .bottom])
                
                Divider()
                
                AnimeList(animeData: $homeViewModel.selectedAnimeData)
            }
            .searchable(
                text: $homeViewModel.filterText,
                prompt: "Filter by name"
            ) {
//                FilterColumn()
                AnimeList(animeData: $homeViewModel.filterResults)
            }
            .onChange(of: homeViewModel.filterText) { newValue in
                homeViewModel.filterDataByTitle(query: newValue)
            }
            .navigationTitle("Anime Tracker")
            .toolbar {
                ToolbarItem {
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
            }
        }
        .onAppear {
            homeViewModel.selectedAnimeData = homeViewModel.selectedData
        }
        .onChange(of: homeViewModel.selectedViewMode) { newValue in
            homeViewModel.selectedAnimeData = homeViewModel.selectedData
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
                .environmentObject(HomeViewModel())
        }
    }
}

// Note:
// ForEach automatically assigns a tag to the selection views using each option’s id. This is possible because ViewMode conforms to the Identifiable protocol.

// 1. Search can be used for filtering and searching data
// 2. Filter is when we HAVE data, we narrow our data
// 3. Search is when we have NO data, we call api to search for more results
