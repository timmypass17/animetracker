//
//  GenreRow.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct GenreRow: View {
    let animeNode: AnimeNode
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 4) {
                ForEach(animeNode.node.genres, id: \.name) { tag in
                    Text(tag.name)
                        .font(.caption)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .font(.body)
                        .background(.secondary)
                        .foregroundColor(Color.white)
                        .cornerRadius(3)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct GenreRow_Previews: PreviewProvider {
    static var previews: some View {
        GenreRow(animeNode: AnimeCollection.sampleData[0])
    }
}
