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
                StatsCell(title: "Alternate Title", image: "clock", value: animeNode.node.getTitle())
                StatsCell(title: "Type", image: "clock", value: animeNode.node.getMediaType())
                StatsCell(title: "Episodes", image: "clock", value: String(animeNode.node.getNumEpisodesOrChapters()))
                StatsCell(title: "Status", image: "clock", value: animeNode.node.getStatus())
                StatsCell(title: "Aired", image: "clock", value: animeNode.node.getAiringTime())
                StatsCell(title: "Premiered", image: "clock", value: animeNode.node.getSeasonYear())
                StatsCell(title: "Broadcast", image: "clock", value: animeNode.node.getBroadcast())
            }

            StatsCell(title: "Studio", image: "clock", value: animeNode.node.getStudios())
            if animeNode.node.source != nil {
                StatsCell(title: "Source", image: "clock", value: animeNode.node.source?.capitalized ?? "?")
            }
            StatsCell(title: "Duration", image: "clock", value: animeNode.node.getEpisodeMinutes())
            StatsCell(title: "Rating", image: "clock", value: animeNode.node.getRatingFormatted())
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
    
    @State var isExpanded = false
    var body: some View {
        VStack {
            Divider()
            
            HStack(alignment: .top) {
                Label(title, systemImage: image)
                    .padding(.trailing)
                
                Spacer()
                Text(value)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(isExpanded ? nil : 1)
            }
            .onTapGesture {
                isExpanded.toggle()
            }
        }
    }
}

struct AnimeStats_Previews: PreviewProvider {
    static var previews: some View {
        AnimeStats(animeNode: AnimeCollection.sampleData[0])
    }
}
