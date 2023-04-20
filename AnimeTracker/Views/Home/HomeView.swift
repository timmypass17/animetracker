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
//        ScrollView {
//            VStack(spacing: 0) {
//                HomeTabView()
//                    .padding([.horizontal, .bottom])
//
//                Divider()
//
//                WatchList(data: animeViewModel.selectedAnimeData)
//                    .padding(.horizontal)
//                    .padding(.trailing, 4) // scooth from scroll axis
//            }
//        }
        
        List {
//            VStack(spacing: 0) {
                HomeTabView()
//                    .padding([.horizontal, .bottom])
//                .padding(.bottom)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.ui.background)
                .padding(.top, -8)
                .padding(.bottom, 8)

            WatchList(data: animeViewModel.selectedAnimeData)
//                    .padding(.horizontal)
//                    .padding(.trailing, 4) // scooth from scroll axis
//            }
        }
        .listStyle(.plain)
        
//        .listRowInsets(EdgeInsets())
        .scrollContentBackground(.hidden)
        .background(Color.ui.background)
//        .toolbar {
//          EditButton()
//        }
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
        .searchable(
            text: $animeViewModel.filterText,
            prompt: "Filter by name"
        ) {
            SearchList(data: animeViewModel.filterResults)
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
            animeViewModel.applySort()
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
                .environmentObject(AnimeViewModel(animeRepository: AnimeRepository(), appState: AppState()))
        }
    }
}
