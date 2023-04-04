//
//  DetailPoster.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct DetailPoster: View {
    let poster: Poster?
    var width: CGFloat = 120
    var height: CGFloat = 120
    
    var body: some View {
        if let poster = poster {
            AsyncImage(url: URL(string: poster.medium)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.secondary)
                    }
                    .shadow(radius: 2)
            } placeholder: {
                ProgressView()
                    .frame(width: width, height: height)
            }
            
        }
    }
}

//struct DetailPoster_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailPoster(animeNode: AnimeCollection.sampleData[0])
//    }
//}
