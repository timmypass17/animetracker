//
//  EpisodeSlider.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/16/23.
//

import SwiftUI

struct ProgressionSlider: View {
    let item: WeebItem
    @Binding var progress: Float
    var maxEpisodeOrChapter: Int
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { handleMinus() }) {
                    Image(systemName: "minus")
                }
                
                // TODO: Some animes don't have num count (ex. One Piece)
                Slider(
                    value: $progress,
                    in: 0.0...Float(maxEpisodeOrChapter),
                    step: 1.0
                ) {
                    Text("Chapter")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("")
                }
                Button(action: { handlePlus() }) {
                    Image(systemName: "plus")
                }
            }
            
            Text("Currently on chapter: \(Int(progress)) / \(maxEpisodeOrChapter)")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.caption)
        }
    }
    
    
    func handlePlus() {
        if let anime = item as? Anime {
            progress = min((progress) + 1, Float(anime.getNumEpisodes()))
        } else if let manga = item as? Manga {
            progress = min((progress) + 1, Float(manga.getNumChapters()))
        }
    }
    
    func handleMinus() {
        progress = max((progress) - 1, 0)
    }
}

struct ProgressionSlider_Previews: PreviewProvider {
    static var previews: some View {
        ProgressionSlider(
            item: SampleData.sampleData[0],
            progress: .constant(15.0),
            maxEpisodeOrChapter: 24
        )
        
        ProgressionSlider(
            item: SampleData.sampleData[0],
            progress: .constant(15.0),
            maxEpisodeOrChapter: 0
        )
    }
}
