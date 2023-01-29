//
//  DiscoverDetailView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/17/23.
//

import SwiftUI

struct DiscoverDetailView: View {
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    var animeData: [AnimeNode] = []
    let season: Season
    let year: Int
    let geometry: GeometryProxy
    let columns: [GridItem]
    
    init(animeData: [AnimeNode], season: Season, year: Int, geometry: GeometryProxy) {
        self.animeData = animeData
        self.season = season
        self.year = year
        self.geometry = geometry
        self.columns = [GridItem(), GridItem(), GridItem()]
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(animeData, id: \.node.id) { animeNode in
                    NavigationLink {
                        AnimeDetail(animeID: animeNode.node.id)
                    } label: {
                        DiscoverCell(animeNode: animeNode, geometry: geometry, width: 0.3)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top)
        }
        .padding()
        .background(Color.ui.background)
    }
}

struct DiscoverDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            DiscoverDetailView(animeData: AnimeCollection.sampleData, season: .fall, year: 2021, geometry: geometry)
                .environmentObject(DiscoverViewModel(animeRepository: AnimeRepository()))
        }
    }
}
