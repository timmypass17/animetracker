//
//  AnimeCell.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import SwiftUI

struct AnimeCell: View {
    @EnvironmentObject var animeViewModel: AnimeViewModel
    var anime: Anime
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            DetailPoster(poster: anime.main_picture, width: 85.0, height: 135.0)
            
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
                
                Label("Next Episode: \(anime.getBroadcast())", systemImage: "clock")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
            }
            
            Spacer()
        }
        .padding(.vertical)
    }
}

struct AnimeCell_Previews: PreviewProvider {
    static var previews: some View {
        AnimeCell(anime: SampleData.sampleData[0] as! Anime)
            .previewLayout(.sizeThatFits)
            .background(Color.ui.background)
    }
}


