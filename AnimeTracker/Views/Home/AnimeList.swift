//
//  HomeColumn.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/9/23.
//

import SwiftUI

struct AnimeList: View {
    @Binding var animeData: [AnimeNode]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach($animeData, id: \.record.recordID) { $animeNode in
                NavigationLink {
                    AnimeDetail(id: animeNode.node.id, animeType: animeNode.node.animeType ?? .anime)
                } label: {
                    AnimeCell(animeNode: $animeNode)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct AnimeList_Previews: PreviewProvider {
    static var previews: some View {
        AnimeList(animeData: .constant(AnimeCollection.sampleData))
    }
}