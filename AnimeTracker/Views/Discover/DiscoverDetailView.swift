//
//  DiscoverDetailView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/17/23.
//

import SwiftUI

struct DiscoverDetailView: View {
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    var animeCollection: AnimeCollection
    let geometry: GeometryProxy
    let animeType: AnimeType
    let columns = [GridItem(), GridItem(), GridItem()]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(animeCollection.data, id: \.node.id) { animeNode in
                    NavigationLink {
                        AnimeDetail(id: animeNode.node.id, animeType: animeType)
                    } label: {
                        DiscoverCell(animeNode: animeNode, geometry: geometry, width: 0.29)
                    }
                    .buttonStyle(.plain)
                }
                
                if animeCollection.paging.next != nil {
                    ProgressView()
                        .onAppear {
                            Task {
                                try await discoverViewModel.loadMore(season: animeCollection.season.season, year: animeCollection.season.year)
                            }
                        }
                }
            }
        }
        .navigationTitle(animeCollection.seasonFormatted())
        .padding()
        .background(Color.ui.background)

    }
}

struct DiscoverDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            DiscoverDetailView(animeCollection: AnimeCollection(data: AnimeCollection.sampleData), geometry: geometry, animeType: .anime)
                .environmentObject(DiscoverViewModel(animeRepository: AnimeRepository()))
        }
    }
}
