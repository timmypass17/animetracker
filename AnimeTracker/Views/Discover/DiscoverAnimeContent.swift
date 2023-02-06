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
//            if discoverViewModel.fallData.data.count > 0 && isRelevant(season: .fall, year: getCurrentYear()) {
//                DiscoverRow(animeCollection: $discoverViewModel.fallData, title: discoverViewModel.fallData.seasonFormatted(), geometry: geometry, animeType: .anime)
//                    .padding(.top)
//            }
//            
//            if discoverViewModel.summerData.data.count > 0 && isRelevant(season: .summer, year: getCurrentYear()) {
//                DiscoverRow(animeCollection: $discoverViewModel.summerData, title: discoverViewModel.summerData.seasonFormatted(), geometry: geometry, animeType: .anime)
//                    .padding(.top)
//            }
//            
//            if discoverViewModel.springData.data.count > 0 && isRelevant(season: .spring, year: getCurrentYear()) {
//                DiscoverRow(animeCollection: $discoverViewModel.springData, title: discoverViewModel.springData.seasonFormatted(), geometry: geometry, animeType: .anime)
//                    .padding(.top)
//            }
//            
//            if discoverViewModel.winterData.data.count > 0 && isRelevant(season: .winter, year: getCurrentYear()) {
//                DiscoverRow(animeCollection: $discoverViewModel.winterData, title: discoverViewModel.winterData.seasonFormatted(), geometry: geometry, animeType: .anime)
//                    .padding(.top)
//            }
//            
//            DiscoverRow(animeCollection: $discoverViewModel.fallDataPrev, title: discoverViewModel.fallDataPrev.seasonFormatted(), geometry: geometry, animeType: .anime)
//                .padding(.top)
//            
//            DiscoverRow(animeCollection: $discoverViewModel.summerDataPrev, title: discoverViewModel.summerDataPrev.seasonFormatted(), geometry: geometry, animeType: .anime)
//                .padding(.top)
//            
//            DiscoverRow(animeCollection: $discoverViewModel.springDataPrev, title: discoverViewModel.springDataPrev.seasonFormatted(), geometry: geometry, animeType: .anime)
//                .padding(.top)
//            
//            DiscoverRow(animeCollection: $discoverViewModel.winterDataPrev, title: discoverViewModel.winterDataPrev.seasonFormatted(), geometry: geometry, animeType: .anime)
//                .padding(.top)
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
