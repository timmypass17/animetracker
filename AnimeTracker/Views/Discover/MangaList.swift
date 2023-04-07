//
//  DiscoverMangaContent.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/30/23.
//

import SwiftUI

struct MangaList: View {
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    var geometry: GeometryProxy
    let mangaTypes: [AnimeType]
    
    var body: some View {
        LazyVStack {
            PopularMangas(geometry: geometry)

            ForEach(mangaTypes) { mangaType in
                if mangaType != .doujin && mangaType != .oneshots {
                    DiscoverRow(
                        title: mangaType.rawValue.capitalized,
                        animeType: mangaType,
                        geometry: geometry,
                        loadMore: discoverViewModel.loadMoreMangas
                    )
                    .padding(.top, 6)
                }
            }
        }
        
    }
}

struct MangaListContent_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            MangaList(geometry: geometry, mangaTypes: [.manga, .novels, .manhwa, .manhua])
                .environmentObject(DiscoverViewModel(animeRepository: AnimeRepository()))
        }
    }
}
