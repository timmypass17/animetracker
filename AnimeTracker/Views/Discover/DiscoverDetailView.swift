//
//  DiscoverDetailView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/17/23.
//

import SwiftUI

struct DiscoverDetailView: View {
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    @State var animeCollection = [WeebItem]()
    @State var page = 0
    let columns = [GridItem(), GridItem(), GridItem()]
    var year: Int = 0
    var season: Season = .fall
    var animeType: AnimeType
    let geometry: GeometryProxy
    var loadMore: (Season, Int, AnimeType, Int) async throws -> [WeebItem]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(animeCollection, id: \.id) { item in
                    NavigationLink {
                        AnimeDetail(id: item.id, type: .anime)
                    } label: {
                        DiscoverCell(animeNode: item, geometry: geometry, width: 0.29, isScaled: true)
                    }
                    .buttonStyle(.plain)
                }
                
                ProgressView()
                    .onAppear {
                        Task {
                            print("OnAppear() \(page) \(season) \(year) \(animeType)")
                            let temp = try await loadMore(season, year, animeType, page)
                            animeCollection.append(contentsOf: temp)
                            page += 1
                        }
                    }
            }
        }
        .padding()
        .background(Color.ui.background)

    }
}

//struct DiscoverDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        GeometryReader { geometry in
//            DiscoverDetailView(year: 0, animeType: .anime, geometry: geometry, loadMore: { _, _, _, _ in return AnimeCollection() })
//                .environmentObject(DiscoverViewModel(animeRepository: AnimeRepository()))
//        }
//    }
//}
