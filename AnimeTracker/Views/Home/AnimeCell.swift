//
//  AnimeCell.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import SwiftUI

struct AnimeCell: View {
    @Binding var animeNode: AnimeNode
    let width = 85.0
    let height = 135.0
    
    var body: some View {
        VStack(spacing: 0) {

            HStack(alignment: .top, spacing: 0) {
                AsyncImage(url: URL(string: animeNode.node.main_picture.medium)) { image in
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
                .padding(.trailing)
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(animeNode.node.startSeasonFormatted())
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        HStack(spacing: 4){
                            Text(animeNode.node.alternative_titles.en)
                        }
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.bottom, 5)
                        
                        HStack(spacing: 4) {
                            let maxTags = 2
                            ForEach(animeNode.node.genres.prefix(maxTags), id: \.name) { tag in
                                TagView(text: tag.name)
                                    .font(.caption)
                            }
                            if animeNode.node.genres.count > maxTags {
                                HStack(spacing: 0) {
                                    Image(systemName: "plus")
                                    Text("\(animeNode.node.genres.count - maxTags) more")
                                }
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .padding(.leading, 2)
                            }
                        }
                    }
                    
                    // progressiveView likes float
                    ProgressView(value: Float(animeNode.episodes_seen), total: Float(animeNode.node.num_episodes)) {
                        HStack(spacing: 4) {
                            AnimeStatus(animeNode: animeNode)
                                .font(.caption)
                            
                            Spacer()

                            Text("Episodes:")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Text("\(animeNode.episodes_seen) /")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Text(animeNode.node.numEpisodesFormatted())
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                        }
                    }
                    .progressViewStyle(.linear)
                    
                    Label("Next episode: \(animeNode.node.broadcastFormatted())", systemImage: "clock")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                }

                Spacer()
            }
            .padding(.vertical)
            
            Divider()
        }
        .contentShape(Rectangle()) // makes whole view clickable
    }
}

struct AnimeCell_Previews: PreviewProvider {
    static var previews: some View {
        AnimeCell(animeNode: .constant(AnimeCollection.sampleData[0]))
    }
}


