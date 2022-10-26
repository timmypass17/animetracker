//
//  HomeView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/23/22.
//

import SwiftUI

//@Published var isSignedInToiCloud: Bool = false
//@Published var permissionStatus: Bool = false
//@Published var error: String = ""
//@Published var userName: String = ""
//@Published var uid: CKRecord.ID?

// ForEach automatically assigns a tag to the selection views using each option’s id. This is possible because ViewMode conforms to the Identifiable protocol.

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Picker("View Mode", selection: $homeViewModel.selectedViewMode) {
                    ForEach(HomeViewModel.ViewMode.allCases) { mode in
                        Text(mode.rawValue.capitalized)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .bottom])
                
                Divider()
                    .padding(.bottom)
                
                ForEach($homeViewModel.animeData, id: \.id) { $anime in
                    AnimeCell(anime: $anime)
                        .padding(.bottom)
                }
                .padding([.horizontal])
                
                Spacer()
            }
            .edgesIgnoringSafeArea(.bottom)
            .toolbar {
                ToolbarItemGroup {
                    NavigationLink {
                        SearchView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("Anime Tracker")
            .searchable(
                text: $homeViewModel.filterText,
                prompt: "Filter by name"
            ) {
                ForEach($homeViewModel.filterResults, id: \.id) { $anime in
                    AnimeCell(anime: $anime)
                        .listRowSeparator(.hidden) // remove default separator
                }
            }
            .onChange(of: homeViewModel.filterText) { newValue in
                homeViewModel.filterResults = homeViewModel.animeData.filter { anime in
                    anime.title.lowercased().contains(newValue.lowercased()) // case insensitive
                }
        }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
                .environmentObject(AuthViewModel())
                .environmentObject(HomeViewModel())
        }
    }
}

// Note:
// 1. Search can be used for filtering and searching data
// 2. Filter is when we HAVE data, we narrow our data
// 3. Search is when we have NO data, we call api to search for more results
