//
//  DiscoverCell.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/13/23.
//

import SwiftUI

struct DiscoverCell: View {
    let item: WeebItem
    let geometry: GeometryProxy
    let width: CGFloat
    var isScaled: Bool = false
    
    var posterWidth: CGFloat {
        geometry.size.width * width // 0.25
        //        geometry.size.width * 0.3
    }
    
    var posterHeight: CGFloat {
        posterWidth / 0.69
    }
    
    var description: String {
        if let anime = item as? Anime {
            return "\(anime.getMediaType().uppercased()) - \(anime.getNumEpisodes()) Episodes"
        }
        if let manga = item as? Manga {
            return "\(manga.getMediaType()) - Ch. \(manga.getNumChapters())"
        }
        
        return "Unknown"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: item.main_picture?.medium ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: isScaled ? posterWidth : 100, height: isScaled ?  posterHeight : 150)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.secondary)
                    }
                    .shadow(radius: 2)
            } placeholder: {
                ProgressView()
                    .frame(width: isScaled ? posterWidth : 100, height: isScaled ?  posterHeight : 150)
            }
            
            Text(item.getTitle())
                .font(.system(size: 14))
                .lineLimit(1)
                .padding(.top, 4)

            Text(description)
                .foregroundColor(Color.ui.textColor.opacity(0.6))
                .font(.system(size: 10))
            
            AnimeStatus(animeNode: item)
                .padding(.top, 2)
                        
        }
        .frame(width: isScaled ? posterWidth : 100)
        .contentShape(RoundedRectangle(cornerRadius: 5)) // fixes overlap click area
    }
}

struct TagView: View {
    var text: String
    var image: Image? = nil
    
    var body: some View {
        HStack {
            image
            
            Text(text)
                .foregroundColor(Color.ui.textColor)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .background{
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.ui.tag)
        }
    }
    
}

struct DiscoverCell_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            DiscoverCell(item: SampleData.sampleData[0], geometry: geometry, width: 0.25)
        }
    }
}
