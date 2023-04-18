//
//  AnimeCell.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import SwiftUI

struct WeebCell: View {
    @EnvironmentObject var animeViewModel: AnimeViewModel
    var item: WeebItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            DetailPoster(poster: item.main_picture, width: 85.0, height: 135.0)
            
            if let anime = item as? Anime {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(anime.getStartSeasonAndYear())")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        HStack(spacing: 4){
                            Text(anime.getTitle())
                        }
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.bottom, 5)
                        
                        GenreRow(animeNode: anime, maxTags: 2)
                            .font(.caption)
                            .scrollDisabled(true)
                    }
                    
                    ProgressView(
                        value: Float(anime.progress?.seen ?? 0),
                        total: Float(anime.getNumEpisodes())
                    ) {
                        HStack(spacing: 4) {
                            AnimeStatus(animeNode: anime)
                                .font(.caption)
                            
                            Spacer()
                            Text("Episodes")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Text("\(anime.progress?.seen ?? 0) /")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Text("\(anime.getNumEpisodes())")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                        }
                        
                    }
                    .progressViewStyle(.linear)
                    
                    HStack {
                        Image(systemName: "clock")
                        
                        Text("Next Episode: \(anime.getBroadcast())")
                    }
                    .foregroundColor(.secondary)
                    .font(.caption)
//                    Label("Next Episode: \(anime.getBroadcast())", systemImage: "clock")
//                        .foregroundColor(.secondary)
//                        .font(.caption)
                }
            } else if let manga = item as? Manga {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(manga.getStartSeasonAndYear())")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        HStack(spacing: 4){
                            Text(manga.getTitle())
                        }
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.bottom, 5)
                        
                        GenreRow(animeNode: manga, maxTags: 2)
                            .font(.caption)
                            .scrollDisabled(true)
                    }
                    
                    ProgressView(
                        value: Float(manga.progress?.seen ?? 0),
                        total: Float(manga.getNumChapters())
                    ) {
                        HStack(spacing: 4) {
                            AnimeStatus(animeNode: manga)
                                .font(.caption)
                            
                            Spacer()
                            Text("Chapter")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Text("\(manga.progress?.seen ?? 0) /")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Text("\(manga.getNumChapters())")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                        }
                        
                    }
                    .progressViewStyle(.linear)
                    
                    HStack {
                        Image(systemName: "clock")
                        
                        Text("Next Chapter: Unknown")
                    }
                    .foregroundColor(.secondary)
                    .font(.caption)
//                    Label("Next Chapter: Unknown", systemImage: "clock")
//                        .foregroundColor(.secondary)
//                        .font(.caption)
                }
            }
            
        }
//        .padding(.vertical)
    }
}

struct AnimeCell_Previews: PreviewProvider {
    static var previews: some View {
        WeebCell(item: SampleData.sampleData[0])
            .previewLayout(.sizeThatFits)
            .background(Color.ui.background)
    }
}


