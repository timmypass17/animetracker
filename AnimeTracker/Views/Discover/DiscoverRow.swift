//
//  DiscoverRow.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/13/23.
//

import SwiftUI

struct DiscoverRow: View {
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    @State var animeCollection = [WeebItem]()
    var title: String = ""
    var year: Int = 0
    var season: Season = .fall
    var animeType: AnimeType
    var geometry: GeometryProxy
    var loadMore: (Season, Int, AnimeType, Int) async throws -> [WeebItem]
    
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
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                HStack {
                    Text(title.uppercased())
                        .foregroundColor(Color.ui.textColor.opacity(0.6))

                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(Color.ui.textColor.opacity(0.6))
                }
                .contentShape(Rectangle())
                .padding(.horizontal)
            }
            .buttonStyle(.plain)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top) {
                    ForEach(animeCollection, id: \.id) { item in
                        NavigationLink {
                            AnimeDetail(id: item.id, type: .anime)
                        } label: {
                            DiscoverCell(animeNode: item, geometry: geometry, width: 0.25)
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
        .onAppear {
            Task {
                if animeCollection.isEmpty {
                    animeCollection = try await loadMore(season, year, animeType, 0)
                }
            }
        }
    }
}

//struct DiscoverRow_Previews: PreviewProvider {
//    static var previews: some View {
//        GeometryReader { geometry in
//            DiscoverRow(title: "Spring 2023", year: 2022, animeType: .anime, geometry: geometry, loadMore: { _, _,_,_ in return AnimeCollection() })
//        }
//    }
//}
