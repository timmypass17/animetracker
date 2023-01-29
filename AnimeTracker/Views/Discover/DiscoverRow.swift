//
//  DiscoverRow.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/13/23.
//

import SwiftUI

struct DiscoverRow: View {
    var animeNodes: [AnimeNode]
    var season: Season
    var year: Int
    var geometry: GeometryProxy
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink {
                DiscoverDetailView(animeData: animeNodes, season: season, year: year, geometry: geometry)
                    .navigationTitle(Text(verbatim: "\(season.rawValue.capitalized) \(year)"))
            } label: {
                HStack {
                    Text(verbatim: "\(season.rawValue.capitalized) \(year)")
                    
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
                    ForEach(animeNodes, id: \.node.id) { animeNode in
                        NavigationLink {
                            AnimeDetail(animeID: animeNode.node.id)
                        } label: {
                            DiscoverCell(animeNode: animeNode, geometry: geometry, width: 0.25)
                            
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            
            Divider()
                .padding(.top)
        }
    }
}

struct DiscoverRow_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            DiscoverRow(animeNodes: AnimeCollection.sampleData, season: .fall, year: 2021, geometry: geometry)
        }
    }
}
