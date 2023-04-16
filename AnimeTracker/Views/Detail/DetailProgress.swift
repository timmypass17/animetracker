//
//  DetailProgress.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct DetailProgress: View {
    @Binding var item: WeebItem?
    
    var body: some View {
        if let anime = item as? Anime {
            
            VStack(alignment: .leading) {
                
                ProgressView(
                    value: Float(anime.progress?.seen ?? 0),
                    total: Float(anime.getNumEpisodes())
                ) {
                    HStack(spacing: 4) {
                        AnimeStatus(animeNode: anime)
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("Episodes:")
                            .font(.caption)
                            .foregroundColor(Color.ui.textColor)
                        
                        Text("\(anime.progress?.seen ?? 0) /")
                            .font(.caption)
                            .foregroundColor(Color.ui.textColor)
                        
                        Text("\(anime.getNumEpisodes())")
                            .font(.caption)
                            .foregroundColor(Color.ui.textColor)
                    }
                }
                .progressViewStyle(.linear)
                
                Label("Next episode: \(anime.getBroadcast())", systemImage: "clock")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        } else if let manga = item as? Manga {
            Text("manga")
        }
    }
}

struct DetailProgress_Previews: PreviewProvider {
    static var previews: some View {
        DetailProgress(item: .constant(SampleData.sampleData[0]))
    }
}
