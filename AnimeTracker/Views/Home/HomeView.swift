//
//  HomeView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/23/22.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var animeViewModel: AnimeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HomeTabView()
                    .padding([.horizontal, .bottom])
                
                Divider()
                
                AnimeList(animeData: $animeViewModel.selectedAnimeData)
                    .padding([.horizontal])
            }
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
        }
        .navigationTitle("Anime Tracker")
        .background(Color.ui.background)
        .searchable(
            text: $animeViewModel.filterText,
            prompt: "Filter by name"
        ) {
            AnimeList(animeData: $animeViewModel.filterResults)
        }
        .onChange(of: animeViewModel.filterText) { newValue in
            animeViewModel.filterDataByTitle(query: newValue)
        }
        .onChange(of: animeViewModel.selectedViewMode) { newValue in
            animeViewModel.applySort()
        }
        .onChange(of: animeViewModel.selectedSort) { newValue in
            animeViewModel.applySort()
        }
        .onAppear {
            // TODO: use user saved defaults
            animeViewModel.applySort()
        }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
                .environmentObject(AnimeViewModel(animeRepository: AnimeRepository()))
        }
    }
}

// Note:
// ForEach automatically assigns a tag to the selection views using each option’s id. This is possible because ViewMode conforms to the Identifiable protocol.

// 1. Search can be used for filtering and searching data
// 2. Filter is when we HAVE data, we narrow our data
// 3. Search is when we have NO data, we call api to search for more results
