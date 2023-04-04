//
//  DetailProgress.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct DetailProgress: View {
    @Binding var animeNode: AnimeNode
    
    var body: some View {
        VStack(alignment: .leading) {
            
            ProgressView(
                value: Float(animeNode.record.seen),
                total: Float(animeNode.node.getNumEpisodesOrChapters())
            ) {
                HStack(spacing: 4) {
                    AnimeStatus(animeNode: animeNode)
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("Episodes:")
                        .font(.caption)
                        .foregroundColor(Color.ui.textColor)
                    
                    Text("\(animeNode.record.seen) /")
                        .font(.caption)
                        .foregroundColor(Color.ui.textColor)
                    
                    Text("\(animeNode.node.getNumEpisodesOrChapters() == 0 ? "?" : String(animeNode.node.getNumEpisodesOrChapters()))")
                        .font(.caption)
                        .foregroundColor(Color.ui.textColor)
                }
            }
            .progressViewStyle(.linear)
            
            Label("Next episode: \(animeNode.node.getBroadcast())", systemImage: "clock")
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
}

//struct DetailProgress_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailProgress(animeNode: .constant(AnimeCollection.sampleData[0]), current_episode: .constant(5.0))
//    }
//}
