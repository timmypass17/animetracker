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
        VStack {
            Picker("View Mode", selection: $homeViewModel.selectedSearchMode) {
                ForEach(HomeViewModel.SearchMode.allCases) { mode in
                    Text(mode.rawValue.capitalized)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom)
            
            Text("Hello, World!")
            
            Spacer()
        }
        .padding([.horizontal, .bottom])
        .searchable(text: $searchViewModel.searchText)
        .onReceive(searchViewModel.$searchText.debounce(for: 0.5, scheduler: RunLoop.main)
        ) { _ in
            // Debounce. Fetch api calls after 0.5 seconds of not typing.
            print("Fetch api data for: \(searchViewModel.searchText)")
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
