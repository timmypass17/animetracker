//
//  AnimeStats.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/17/23.
//

import SwiftUI

struct AnimeStats: View {
    let item: WeebItem?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Information".uppercased())
                .foregroundColor(Color.ui.textColor.opacity(0.6))
            
            StatsCell(title: "Alternate Title", image: "t.square", value: item?.getTitle() ?? "Unknown")
            
            StatsCell(title: "Type", image: "magnifyingglass", value: item?.getMediaType().uppercased() ?? "Unknown")
            
            if let anime = item as? Anime {
                StatsCell(title: "Episodes",image: "tv",value: anime.getNumEpisodes())
                StatsCell(title: "Minutes",image: "clock",value: anime.getAverageEpisodeDuration())
                StatsCell(title: "Broadcast", image: "calendar", value: anime.getBroadcast())
                StatsCell(title: "Studio", image: "building", value: anime.getStudios())
                StatsCell(title: "Source", image: "book.closed", value: anime.getSource())
                StatsCell(title: "Rating", image: "r.square.fill", value: anime.getRating())
            }
            else if let manga = item as? Manga {
                StatsCell(title: "Chapter",image: "book",value: manga.getNumChapters())
                StatsCell(title: "Volumes",image: "book",value: manga.getNumVolumes())
            }
            
            StatsCell(title: "Status", image: "leaf", value: item?.getStatus() ?? "Unknown")
            StatsCell(title: "Aired", image: "calendar", value: item?.getStartSeasonAndYear() ?? "Unknown")
            
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 4)
                .fill(.regularMaterial)
        }
    }
}

struct StatsCell<T: CustomStringConvertible>: View {
    let title: String
    let image: String
    let value: T
    
    @State var isExpanded = false
    var body: some View {
        VStack {
            Divider()
            
            HStack(alignment: .top) {
                Label(title, systemImage: image)
                    .foregroundColor(Color.ui.textColor)
                    .padding(.trailing)
                
                Spacer()
                Text("\(value.description)")
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
        AnimeStats(item: SampleData.sampleData[0])
    }
}
