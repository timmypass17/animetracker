//
//  RecommendationRow.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/14/23.
//

import SwiftUI

struct RecommendationRow: View {
    let recommendedItems: [Recommendation]
    let type: WeebItemType
    
    var body: some View {
        if recommendedItems.count > 0 {
            VStack(alignment: .leading) {
                Text("Recommended".uppercased())
                    .foregroundColor(Color.ui.textColor.opacity(0.6))

                ScrollView(.horizontal) {
                    HStack(alignment: .top) {
                        ForEach(recommendedItems, id: \.node.id) { item in
                            NavigationLink {
                                AnimeDetail(id: item.node.id, type: type)
                            } label: {
                                RecommendationCell(recommendedItem: item)
                            }
                            .buttonStyle(.plain)
                            //                            RelatedRowCell(relatedAnimeNode: animeNode)
                        }
                    }
                }
            }
        }
    }
}

struct RecommendationCell: View {
    let recommendedItem: Recommendation
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: recommendedItem.node.mainPicture.medium)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.secondary)
                    }
                    .shadow(radius: 2)
            } placeholder: {
                ProgressView()
                    .frame(width: 100, height: 150)
            }

            Text(recommendedItem.node.title)
                .lineLimit(2)
                .foregroundColor(Color.ui.textColor)
        }
        .frame(width: 100)
        .contentShape(RoundedRectangle(cornerRadius: 5)) // fixes overlap click area
    }
}


//struct RecommendationRow_Previews: PreviewProvider {
//    static var previews: some View {
//        RecommendationRow()
//    }
//}
