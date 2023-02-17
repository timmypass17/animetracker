//
//  DiscoverRow.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/13/23.
//

import SwiftUI

struct DiscoverRow: View {
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    @State var animeCollection = AnimeCollection()
    var title: String = ""
    var year: Int = 0
    var season: Season = .fall
    var animeType: AnimeType
    var geometry: GeometryProxy
    var loadMore: (Int, Season, Int, AnimeType) async throws -> AnimeCollection
    
    var body: some View {
        LazyVStack {
            NavigationLink {
                DiscoverDetailView(
                    year: year,
                    season: season,
                    animeType: animeType,
                    geometry: geometry,
                    loadMore: loadMore
                )
                    .navigationTitle(title)
            } label: {
                HStack {
                    Text(title)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                }
                .contentShape(Rectangle())
                .padding(.horizontal)
            }
            .buttonStyle(.plain)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top) {
                    ForEach(animeCollection.data, id: \.node.id) { animeNode in
                        NavigationLink {
                            AnimeDetail(id: animeNode.node.id, animeType: animeType)
                        } label: {
                            DiscoverCell(animeNode: animeNode, geometry: geometry, width: 0.25)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .frame(minHeight: 175)
            
            Divider()
                .padding(.top)
        }
//        .background(.blue)
        .onAppear {
            Task {
                if animeCollection.data.isEmpty {
                    animeCollection = try await loadMore(0, season, year, animeType)
                    print("fetching \(season) \(year) \(animeType)")
                }
            }
        }
    }
}

struct DiscoverRow_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            DiscoverRow(title: "Spring 2023", year: 2022, animeType: .anime, geometry: geometry, loadMore: { _, _,_,_ in return AnimeCollection() })
        }
    }
}
