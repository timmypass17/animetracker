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
                .foregroundColor(Color.ui.textColor.opacity(0.6))
            
            StatsCell(title: "Alternate Title", image: "t.square.fill", value: animeNode.node.getTitle())
            
            StatsCell(title: "Type", image: "magnifyingglass", value: animeNode.node.getMediaType().uppercased())
            
            Group {
                StatsCell(
                    title: animeNode.node.getEpisodesOrChapters(),
                    image: animeNode.node.animeType == .anime ? "tv" : "book",
                    value: String(animeNode.node.getNumEpisodesOrChapters())
                )
                
                if animeNode.node.num_volumes != nil {
                    StatsCell(title: "Volumes", image: "books.vertical", value: animeNode.node.getNumVolume())
                }
                
                StatsCell(title: "Status", image: "leaf", value: animeNode.node.getStatus())
                
                StatsCell(title: "Aired", image: "calendar", value: animeNode.node.getAiringTime())
                
                if animeNode.node.start_season != nil {
                    StatsCell(title: "Premiered", image: "calendar", value: animeNode.node.getSeasonYear())
                }
                
                StatsCell(title: "Broadcast", image: "calendar", value: animeNode.node.getBroadcast())
                
                StatsCell(title: "Studio", image: "building", value: animeNode.node.getStudios())
            }
            
            StatsCell(title: "Source", image: "book.closed", value: animeNode.node.source?.capitalized ?? "?")
            
            StatsCell(title: "Duration", image: "clock", value: animeNode.node.getEpisodeMinutes())
            
            StatsCell(title: "Rating", image: "r.square.fill", value: animeNode.node.getRatingFormatted().uppercased())
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
                    .foregroundColor(Color.ui.textColor)
                    .padding(.trailing)
                
                Spacer()
                Text(value)
                    .foregroundColor(Color.ui.textColor.opacity(0.6))
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
