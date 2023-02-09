//
//  DiscoverDetailView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/17/23.
//

import SwiftUI

struct DiscoverDetailView: View {
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    @State var animeCollection = AnimeCollection()
    @State var page = 0
    let columns = [GridItem(), GridItem(), GridItem()]
    var animeType: AnimeType
    let geometry: GeometryProxy
    var loadMore: (Int, AnimeType) async throws -> AnimeCollection
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach($animeCollection.data, id: \.node.id) { $animeNode in
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
                                let temp = try await loadMore(page, animeType)
                                animeCollection.data.append(contentsOf: temp.data)
                                page += 1
                            }
                        }
                }
            }
        }
        .padding()
        .background(Color.ui.background)

    }
}

struct DiscoverDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            DiscoverDetailView(page: 0, animeType: .anime, geometry: geometry, loadMore: { _, _ in return AnimeCollection() })
                .environmentObject(DiscoverViewModel(animeRepository: AnimeRepository()))
        }
    }
}
