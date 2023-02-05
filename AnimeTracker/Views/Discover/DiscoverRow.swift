//
//  DiscoverRow.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/13/23.
//

import SwiftUI

struct DiscoverRow: View {
    @Binding var animeCollection: AnimeCollection
//    @Binding var animeNodes: [AnimeNode]
//    var title: String
    var geometry: GeometryProxy
    var animeType: AnimeType
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink {
                DiscoverDetailView(animeCollection: animeCollection, geometry: geometry, animeType: animeType)
            } label: {
                HStack {
                    Text(animeCollection.seasonFormatted())
                    
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
            
            Divider()
                .padding(.top)
        }
    }
}

struct DiscoverRow_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            DiscoverRow(animeCollection: .constant(AnimeCollection(data: AnimeCollection.sampleData)), geometry: geometry, animeType: .anime)
        }
    }
}
