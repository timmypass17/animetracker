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
            
            ProgressView(value: Float(animeNode.record["episodes_seen"] as? Int ?? 0), total: Float(animeNode.node.num_episodes)) {
                HStack(spacing: 4) {
                    Text("Status: \(animeNode.node.status.capitalized.replacingOccurrences(of: "_", with: " "))")
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("Episodes:")
                        .font(.caption)
                    
                    Text("\(animeNode.record["episodes_seen"] as? Int ?? 0)")
                        .font(.caption)
                    
                    Text(verbatim: "/ \(animeNode.node.num_episodes.description)")
                        .font(.caption)
                }
            }
            .progressViewStyle(.linear)
            
            Label("Next episode: \(Date().formatted(date: .abbreviated, time: .shortened))", systemImage: "clock")
                .font(.caption)
        }
    }
}

struct DetailProgress_Previews: PreviewProvider {
    static var previews: some View {
        DetailProgress(animeNode: .constant(AnimeCollection.sampleData[0]))
    }
}
