//
//  DiscoverAnimeContent.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/30/23.
//

import SwiftUI

struct DiscoverAnimeContent: View {
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    var geometry: GeometryProxy
    
    var body: some View {
        // Only show relevant season of this year!
        VStack {
            if discoverViewModel.fallData.data.count > 0 && isRelevant(season: .fall, year: getCurrentYear()) {
                DiscoverRow(animeCollection: $discoverViewModel.fallData, geometry: geometry, animeType: .anime)
                    .padding(.top)
            }
            
            if discoverViewModel.summerData.data.count > 0 && isRelevant(season: .summer, year: getCurrentYear()) {
                DiscoverRow(animeCollection: $discoverViewModel.summerData, geometry: geometry, animeType: .anime)
                    .padding(.top)
            }
            
            if discoverViewModel.springData.data.count > 0 && isRelevant(season: .spring, year: getCurrentYear()) {
                DiscoverRow(animeCollection: $discoverViewModel.springData, geometry: geometry, animeType: .anime)
                    .padding(.top)
            }
            
            if discoverViewModel.winterData.data.count > 0 && isRelevant(season: .winter, year: getCurrentYear()) {
                DiscoverRow(animeCollection: $discoverViewModel.winterData, geometry: geometry, animeType: .anime)
                    .padding(.top)
            }
            
            DiscoverRow(animeCollection: $discoverViewModel.fallDataPrev, geometry: geometry, animeType: .anime)
                .padding(.top)
            
            DiscoverRow(animeCollection: $discoverViewModel.summerDataPrev, geometry: geometry, animeType: .anime)
                .padding(.top)
            
            DiscoverRow(animeCollection: $discoverViewModel.springDataPrev, geometry: geometry, animeType: .anime)
                .padding(.top)
            
            DiscoverRow(animeCollection: $discoverViewModel.winterDataPrev, geometry: geometry, animeType: .anime)
                .padding(.top)
        }
        
    }
    
    func isRelevant(season: Season, year: Int) -> Bool {
        let relevant = discoverViewModel.getRecentSeasonYear()
        return relevant.contains { $0 == (season, year) }
    }
}

struct DiscoverAnimeContent_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            DiscoverAnimeContent(geometry: geometry)
                .environmentObject(DiscoverViewModel(animeRepository: AnimeRepository()))
        }
    }
}
