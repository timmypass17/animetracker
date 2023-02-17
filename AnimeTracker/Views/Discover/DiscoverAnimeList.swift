//
//  DiscoverAnimeContent.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/30/23.
//

import SwiftUI

struct DiscoverAnimeList: View {
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    var geometry: GeometryProxy
    
    var years: ClosedRange<Int> {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = dateFormatter.string(from: date)
        return 1990...Int(currentYear)!
    }
    
    var currentYear: Int {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = dateFormatter.string(from: date)
        return Int(currentYear)!
    }
    
    var body: some View {
        LazyVStack {
            ForEach(years.reversed(), id: \.self) { year in
                
                if isRelevant(season: .fall, year: year) {
                    DiscoverRow(
                        title: "Fall \(year)",
                        year: year,
                        season: .fall,
                        animeType: .anime,
                        geometry: geometry,
                        loadMore: discoverViewModel.loadMoreAnimes)
                    .padding(.top)
                }
                
                if isRelevant(season: .summer, year: year) {
                    
                    DiscoverRow(
                        title: "Summer \(year)",
                        year: year,
                        season: .summer,
                        animeType: .anime,
                        geometry: geometry,
                        loadMore: discoverViewModel.loadMoreAnimes)
                    .padding(.top)
                }
                
                if isRelevant(season: .spring, year: year) {
                    
                    DiscoverRow(
                        title: "Spring \(year)",
                        year: year,
                        season: .spring,
                        animeType: .anime,
                        geometry: geometry,
                        loadMore: discoverViewModel.loadMoreAnimes)
                    .padding(.top)
                }
                
                if isRelevant(season: .winter, year: year) {
                    
                    DiscoverRow(
                        title: "Winter \(year)",
                        year: year,
                        season: .winter,
                        animeType: .anime,
                        geometry: geometry,
                        loadMore: discoverViewModel.loadMoreAnimes)
                    .padding(.top)
                }
            }
        }
    }
    
    func isRelevant(season: Season, year: Int) -> Bool {
        guard year == currentYear else { return true }
        let currentSeason = getCurrentSeason()
        
        let prio: [Season: Int] = [
            .winter: 0,
            .spring: 1,
            .summer: 2,
            .fall: 3
        ]
        
        return prio[season]! <= prio[currentSeason]!
    }
    
    func getCurrentSeason() -> Season {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: date)
        
        switch month {
        case "January", "February", "March":
            return .winter
        case "April", "May", "June":
            return .spring
        case "July", "August", "September":
            return .summer
        default:
            return .fall
        }
    }
}


struct DiscoverAnimeContent_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            DiscoverAnimeList(geometry: geometry)
                .environmentObject(DiscoverViewModel(animeRepository: AnimeRepository()))
        }
    }
}
