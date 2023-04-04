//
//  DetailBackground.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct DetailBackground: View {
    let url: String

    let gradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color.ui.background, location: 0),
            .init(color: .clear, location: 1.0) // 1.5 height of gradient
        ]),
        startPoint: .bottom,
        endPoint: .top
    )
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(height: 350)
                .clipShape(Rectangle())
                .overlay {
                    gradient
                }
                .clipped()
        } placeholder: {
//            ProgressView()
//                .frame(height: 350)
        }
    }
}
//
//struct DetailBackground_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailBackground(poster: AnimeCollection.sampleData[0].node.main_picture)
//    }
//}
