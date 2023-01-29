//
//  DiscoverCell.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/13/23.
//

import SwiftUI

struct DiscoverCell: View {
    let animeNode: AnimeNode
    let geometry: GeometryProxy
    let width: CGFloat
    
    var posterWidth: CGFloat {
        geometry.size.width * width // 0.25
        //        geometry.size.width * 0.3
    }
    
    var posterHeight: CGFloat {
        posterWidth / 0.69
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: animeNode.node.main_picture.medium)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: posterWidth, height: posterHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.secondary)
                    }
                    .shadow(radius: 2)
            } placeholder: {
                ProgressView()
                    .frame(width: posterWidth, height: posterHeight)
            }
            
            Text(animeNode.node.titleFormatted())
                .font(.system(size: 14))
                .lineLimit(1)
                .padding(.top, 4)
            
            Text("\(animeNode.node.media_type.uppercased()) - \(animeNode.node.numEpisodesFormatted()) Episodes")
                .foregroundColor(.white.opacity(0.6))
                .font(.system(size: 10))
            
            AnimeStatus(animeNode: animeNode)
                .padding(.top, 2)
        }
        .frame(width: posterWidth)
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
        }
        .foregroundColor(Color.ui.tag_text)
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
            DiscoverCell(animeNode: AnimeCollection.sampleData[0], geometry: geometry, width: 0.25)
        }
    }
}
