//
//  RelatedRow.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct RelatedRow: View {
    let title: String
    let relatedAnimes: [Anime.RelatedNode]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title.uppercased())
                .foregroundColor(.white.opacity(0.6))
            
            if relatedAnimes.count == 0 {
                Text("Not found.")
            } else {
                ScrollView(.horizontal) {
                    HStack(alignment: .top) {
                        ForEach(relatedAnimes, id: \.node.id) { animeNode in
                            NavigationLink {
                                AnimeDetail(animeID: animeNode.node.id)
                            } label: {
                                RelatedRowCell(relatedAnimeNode: animeNode)
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

struct RelatedRowCell: View {
    let relatedAnimeNode: Anime.RelatedNode
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: relatedAnimeNode.node.main_picture.medium)) { image in
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
            
            if let relation = relatedAnimeNode.relation_type_formatted {
                Text(relation.uppercased())
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 12))
            }

            Text(relatedAnimeNode.node.title)
                .lineLimit(2)
                
        }
        .frame(width: 100)
        .contentShape(RoundedRectangle(cornerRadius: 5)) // fixes overlap click area
    }
}


struct RelatedRow_Previews: PreviewProvider {
    static var previews: some View {
        RelatedRow(
            title: "Related Anime",
            relatedAnimes: AnimeCollection.sampleData[0].node.related_anime ?? []
        )
    }
}
