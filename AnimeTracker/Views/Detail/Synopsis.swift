//
//  Synopsis.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct Synopsis: View {
    let animeNode: AnimeNode
    @State var showMore = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Synopsis".uppercased())
                .foregroundColor(.white.opacity(0.6))
            
            Text(animeNode.node.synopsis)
                .fixedSize(horizontal: false, vertical: true) // fixes text from being truncated "..." somehow
                .lineLimit(showMore ? nil : 4)
            
            Button(action: {
                withAnimation {
                    showMore.toggle()
                    print(animeNode.node.synopsis)
                }
            }) {
                HStack(alignment: .firstTextBaseline, spacing:  4) {
                    Text(showMore ? "Show less" : "Show more")
                        .padding(.top, 2)
                    Image(systemName: showMore ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
        }
    }
}

struct Synopsis_Previews: PreviewProvider {
    static var previews: some View {
        Synopsis(animeNode: AnimeCollection.sampleData[0])
    }
}
