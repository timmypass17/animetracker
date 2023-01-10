//
//  DetailPoster.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct DetailPoster: View {
    let animeNode: AnimeNode
    
    var body: some View {
        AsyncImage(url: URL(string: animeNode.node.main_picture.medium)) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.secondary)
                }
                .shadow(radius: 2)
        } placeholder: {
            ProgressView()
                .frame(width: 120, height: 200)
        }
    }
}

struct DetailPoster_Previews: PreviewProvider {
    static var previews: some View {
        DetailPoster(animeNode: AnimeCollection.sampleData[0])
    }
}
