//
//  AnimeCellDetail.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 11/5/22.
//

import SwiftUI

struct AnimeCellDetail: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    let anime: Anime

    var body: some View {
        Button("Add", action: { homeViewModel.addAnime(anime: anime) })
    }
}

struct AnimeCellDetail_Previews: PreviewProvider {
    static var previews: some View {
        AnimeCellDetail(anime: AnimeCollection.sampleData[0].node)
    }
}
