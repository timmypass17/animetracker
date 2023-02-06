//
//  DiscoverMangaContent.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/30/23.
//

import SwiftUI

struct DiscoverMangaContent: View {
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    var geometry: GeometryProxy
    
    var body: some View {
        VStack {
            DiscoverRow(animeCollection: $discoverViewModel.mangaData, title: "Mangas", geometry: geometry, animeType: .manga, ranking: "manga")
                .padding(.top)
            
            DiscoverRow(animeCollection: $discoverViewModel.novelData, title: "Novels", geometry: geometry, animeType: .manga, ranking: "novels")
                .padding(.top)
            
            DiscoverRow(animeCollection: $discoverViewModel.manhwaData, title: "Manhwas", geometry: geometry, animeType: .manga, ranking: "manhwa")
                .padding(.top)
            
            DiscoverRow(animeCollection: $discoverViewModel.manhuaData, title: "Manhuas", geometry: geometry, animeType: .manga, ranking: "manhua")
                .padding(.top)
        }
        
    }
}

struct DiscoverMangaContent_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            DiscoverMangaContent(geometry: geometry)
                .environmentObject(DiscoverViewModel(animeRepository: AnimeRepository()))
        }
    }
}
