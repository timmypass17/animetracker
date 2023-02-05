//
//  DetailProgress.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct DetailProgress: View {
    @Binding var animeNode: AnimeNode
    @Binding var current_episode: Float
    
    var body: some View {
        VStack(alignment: .leading) {
            
            ProgressView(value: Float(animeNode.episodes_seen), total: Float(animeNode.node.num_episodes ?? 0)) {
                HStack(spacing: 4) {
                    AnimeStatus(animeNode: animeNode)
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("Episodes:")
                        .font(.caption)
                    
                    Text("\(animeNode.episodes_seen)")
                        .font(.caption)
                    
                    Text(verbatim: "/ \(animeNode.node.numEpisodesFormatted())")
                        .font(.caption)
                }
            }
            .progressViewStyle(.linear)
            
            Label("Next episode: \(animeNode.node.broadcastFormatted())", systemImage: "clock")
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
}

struct DetailProgress_Previews: PreviewProvider {
    static var previews: some View {
        DetailProgress(animeNode: .constant(AnimeCollection.sampleData[0]), current_episode: .constant(5.0))
    }
}
