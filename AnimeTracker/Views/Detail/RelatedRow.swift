//
//  RelatedRow.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct RelatedRow: View {
    let relatedItems: [RelatedItem]
    let type: WeebItemType
    
    var body: some View {
        if relatedItems.count > 0 {
            VStack(alignment: .leading) {
                Text("Related \(type.rawValue)".uppercased())
                    .foregroundColor(Color.ui.textColor.opacity(0.6))

                ScrollView(.horizontal) {
                    HStack(alignment: .top) {
                        ForEach(relatedItems, id: \.node.id) { item in
                            NavigationLink {
                                // TODO: Remove type, not needed
                                AnimeDetail(id: item.node.id, type: type)
                            } label: {
                                RelatedRowCell(relatedItem: item)
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
    let relatedItem: RelatedItem
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: relatedItem.node.mainPicture.medium)) { image in
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

            if let relation = relatedItem.relation_type_formatted {
                Text(relation.uppercased())
                    .foregroundColor(Color.ui.textColor.opacity(0.6))
                    .font(.system(size: 12))
            }

            Text(relatedItem.node.title)
                .lineLimit(2)
                .foregroundColor(Color.ui.textColor)
        }
        .frame(width: 100)
        .contentShape(RoundedRectangle(cornerRadius: 5)) // fixes overlap click area
    }
}


struct RelatedRow_Previews: PreviewProvider {
    static var previews: some View {
        RelatedRow(
            relatedItems: [],
            type: .anime
        )
    }
}
