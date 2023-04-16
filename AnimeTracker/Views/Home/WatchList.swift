//
//  HomeColumn.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/9/23.
//

import SwiftUI

struct WatchList: View {
    @EnvironmentObject var animeViewModel: AnimeViewModel

    var body: some View {
        VStack(spacing: 0) {
            ForEach(animeViewModel.userAnimeMangaList, id: \.id) { item in
                NavigationLink {
                    AnimeDetail(id: item.id, type: item is Anime ? .anime : .manga)
                } label: {
                    if let anime = item as? Anime {
                        AnimeCell(anime: anime)
                    }
                    else if let manga = item as? Manga {
                        MangaCell(manga: manga)
                    }
                }
                .buttonStyle(.plain)
                
                Divider()
            }
        }
    }
}

struct WatchList_Previews: PreviewProvider {
    static var previews: some View {
        WatchList()
            .environmentObject(
                AnimeViewModel(
                    animeRepository: AnimeRepository(animeData: SampleData.sampleData)
                )
            )
    }
}
