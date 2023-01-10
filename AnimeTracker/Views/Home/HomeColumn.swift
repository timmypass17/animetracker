//
//  HomeColumn.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/9/23.
//

import SwiftUI

struct HomeColumn: View {
    @Binding var animeData: [AnimeNode]

    var body: some View {
        VStack(spacing: 0) {
            ForEach($animeData, id: \.record.recordID) { $animeNode in
                NavigationLink {
                    AnimeDetail(animeID: animeNode.node.id)
                } label: {
                    AnimeCell(animeNode: $animeNode)
                }
                .buttonStyle(.plain)
            }
            .padding([.horizontal])
        }
    }
}

struct HomeColumn_Previews: PreviewProvider {
    static var previews: some View {
        HomeColumn(animeData: .constant(AnimeCollection.sampleData))
    }
}
