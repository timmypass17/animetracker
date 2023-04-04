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
                .foregroundColor(Color.ui.textColor.opacity(0.6))
            
            Text(animeNode.node.getSynopsis())
                .fixedSize(horizontal: false, vertical: true) // fixes text from being truncated "..." somehow
                .lineLimit(showMore ? nil : 4)
                .foregroundColor(Color.ui.textColor)
            
            Button(action: {
                withAnimation {
                    showMore.toggle()
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 4)
                .fill(.regularMaterial)
        }
    }
}

struct Synopsis_Previews: PreviewProvider {
    static var previews: some View {
        Synopsis(animeNode: AnimeCollection.sampleData[0])
    }
}
