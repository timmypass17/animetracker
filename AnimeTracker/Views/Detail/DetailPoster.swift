//
//  DetailPoster.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct DetailPoster: View {
    let poster: MainPicture?
    var width: CGFloat
    var height: CGFloat
    
    
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
        } else {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(.placeholderText))
                .frame(width: width, height: height)
        }
    }
}

struct DetailPoster_Previews: PreviewProvider {
    static var previews: some View {
        DetailPoster(poster: SampleData.sampleData[0].main_picture, width: 85, height: 135)
    }
}
