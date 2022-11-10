//
//  AnimeCellDetail.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 11/5/22.
//

import SwiftUI

struct AnimeCellDetail: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Binding var animeNode: AnimeNode

    var body: some View {
        Text(animeNode.record.recordID.recordName)
        Text(animeNode.node.title)
        Button("Add", action: {
            Task {
                await homeViewModel.addAnime(anime: animeNode.node)
            }
            
        })
        Button("Delete", action: {
            Task {
                await homeViewModel.deleteAnime(recordToDelete: animeNode.record)
            }
            
        })

    }
}

struct AnimeCellDetail_Previews: PreviewProvider {
    static var previews: some View {
        AnimeCellDetail(animeNode: .constant(AnimeCollection.sampleData[0]))
    }
}
