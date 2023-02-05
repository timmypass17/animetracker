//
//  AnimeStats.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/17/23.
//

import SwiftUI

struct AnimeStats: View {
    let animeNode: AnimeNode
        
    var body: some View {
        VStack(alignment: .leading) {
            Text("Information".uppercased())
                .foregroundColor(.white.opacity(0.6))
            
            Group {
                StatsCell(title: "Alternate Title", image: "clock", value: animeNode.node.alternative_titles.en)
                StatsCell(title: "Type", image: "clock", value: animeNode.node.media_type.uppercased())
                StatsCell(title: "Episodes", image: "clock", value: String(animeNode.node.numEpisodesFormatted()))
                StatsCell(title: "Status", image: "clock", value: animeNode.node.statusFormatted())
                StatsCell(title: "Aired", image: "clock", value: animeNode.node.airedDateFormatted())
                StatsCell(title: "Premiered", image: "clock", value: animeNode.node.startSeasonFormatted())
                StatsCell(title: "Broadcast", image: "clock", value: animeNode.node.broadcastFormatted())
            }

            StatsCell(title: "Studio", image: "clock", value: animeNode.node.studiosFormatted())
            StatsCell(title: "Source", image: "clock", value: animeNode.node.source?.capitalized ?? "")
            StatsCell(title: "Duration", image: "clock", value: animeNode.node.averageEpisodeDurationFormatted())
            StatsCell(title: "Rating", image: "clock", value: animeNode.node.rating?.capitalized ?? "?")
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 4)
                .fill(.regularMaterial)
        }
    }
}

struct StatsCell: View {
    let title: String
    let image: String
    let value: String
    
    var body: some View {
        VStack {
            Divider()
            
            HStack(alignment: .top) {
                Label(title, systemImage: image)
                Spacer()
                Text(value)
                    .foregroundColor(.white.opacity(0.6))

            }
        }
    }
}

struct AnimeStats_Previews: PreviewProvider {
    static var previews: some View {
        AnimeStats(animeNode: AnimeCollection.sampleData[0])
    }
}
