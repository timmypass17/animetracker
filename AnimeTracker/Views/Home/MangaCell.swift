//
//  MangaCell.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/14/23.
//

import SwiftUI

struct MangaCell: View {
    @EnvironmentObject var animeViewModel: AnimeViewModel
    var manga: Manga
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            DetailPoster(poster: manga.main_picture, width: 85.0, height: 135.0)
            
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
                        Text("Episodes")
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
                
                Label("Next Chapter: Unknown", systemImage: "clock")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
            }
            
            Spacer()
        }
        .padding(.vertical)
    }
}

struct MangaCell_Previews: PreviewProvider {
    static var previews: some View {
        MangaCell(manga: SampleData.sampleData[1] as! Manga)
    }
}
