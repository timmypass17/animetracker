//
//  GenreRow.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct GenreRow: View {
    let animeNode: WeebItem?
    var maxTags = Int.max
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(animeNode?.genres?.prefix(maxTags) ?? [], id: \.name) { tag in
                    TagView(text: tag.name)
                }
                
                if animeNode?.genres?.count ?? 0 > maxTags {
                    HStack(spacing: 0) {
                        Image(systemName: "plus")
                        Text("\((animeNode?.genres?.count ?? 0) - maxTags) more")
                    }
                    .foregroundColor(.secondary)
                    .padding(.leading, 2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct GenreRow_Previews: PreviewProvider {
    static var previews: some View {
        GenreRow(animeNode: SampleData.sampleData[0])
    }
}
