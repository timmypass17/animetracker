//
//  HomeView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/23/22.
//

import SwiftUI
import CloudKit

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var animeViewModel: AnimeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HomeTabView()
                    .padding([.horizontal, .bottom])

                Divider()
                
                WatchList()
                    .padding([.horizontal])
            }
        }
        .navigationTitle("My Anime List")
        .toolbar {
            ToolbarItem {
                Menu {
                    Picker("Sort By", selection: $animeViewModel.selectedSort) {
                        Label("Newest", systemImage: "leaf")
                            .tag(SortBy.newest)
                        
                        Label("Alphabetical", systemImage: "textformat.abc")
                            .tag(SortBy.alphabetical)
                        
                        Label("Date Added", systemImage: "calendar")
                            .tag(SortBy.date_created)
                        

                        Label("Last Modified", systemImage: "clock")
                            .tag(SortBy.last_modified)
                    }
                } label: {
                    Label("Add Bookmark", systemImage: "line.3.horizontal.decrease")
                }
            }
        }
        .background(Color.ui.background)
        .searchable(
            text: $animeViewModel.filterText,
            prompt: "Filter by name"
        ) {
//            WatchList()
        }
        .onChange(of: animeViewModel.filterText) { newValue in
//            animeViewModel.filterDataByTitle(query: newValue)
        }
        .onChange(of: animeViewModel.selectedViewMode) { newValue in
//            animeViewModel.applySort()
        }
        .onChange(of: animeViewModel.selectedSort) { newValue in
//            animeViewModel.applySort()
        }
        .onAppear {
//            animeViewModel.applySort()
        }
        .refreshable {
            Task{
                await animeViewModel.loadUserAnimeList()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
                .environmentObject(AppState())
                .environmentObject(AnimeViewModel(animeRepository: AnimeRepository()))
        }
    }
}
