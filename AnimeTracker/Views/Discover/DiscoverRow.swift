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
    var title: String
    var animeType: AnimeType
    var geometry: GeometryProxy
    var loadMore: (Int, AnimeType) async throws -> AnimeCollection
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink {
                DiscoverDetailView(animeType: animeType, geometry: geometry, loadMore: loadMore)
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
            
            Divider()
                .padding(.top)
        }
        .onAppear {
            Task {
                animeCollection = try await loadMore(0, animeType)
            }
        }
    }
}

struct DiscoverRow_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            DiscoverRow(title: "Spring 2023", animeType: .anime, geometry: geometry, loadMore: { _, _ in return AnimeCollection() }) 
        }
    }
}
