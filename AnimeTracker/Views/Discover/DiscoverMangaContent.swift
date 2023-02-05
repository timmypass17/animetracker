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
    var animeType: AnimeType
    
    var body: some View {
        VStack {
//            DiscoverRow(animeNodes: $discoverViewModel.mangaData, title: "Top Mangas", geometry: geometry, animeType: .manga)
//                .padding(.top)
//            
//            DiscoverRow(animeNodes: $discoverViewModel.novelData, title: "Top Novels", geometry: geometry, animeType: animeType)
//                .padding(.top)
//            
//            DiscoverRow(animeNodes: $discoverViewModel.manhwaData, title: "Top Manhwa", geometry: geometry, animeType: animeType)
//                .padding(.top)
//            
//            DiscoverRow(animeNodes: $discoverViewModel.manhuaData, title: "Top Manhua", geometry: geometry, animeType: animeType)
//                .padding(.top)
        }
        
    }
}

struct DiscoverMangaContent_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            DiscoverMangaContent(geometry: geometry, animeType: .manga)
                .environmentObject(DiscoverViewModel(animeRepository: AnimeRepository()))
        }
    }
}
