//
//  AnimeCell.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import SwiftUI

struct AnimeCell: View {
    @Binding var animeNode: AnimeNode
    
    var body: some View {
        VStack(spacing: 0) {

            HStack(alignment: .top, spacing: 0) {
                AsyncImage(url: URL(string: animeNode.node.main_picture.medium)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 75, height: 125)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.secondary)
                        }
                        .shadow(radius: 2)
                } placeholder: {
                    ProgressView()
                        .frame(width: 75, height: 125)
                }
                .padding(.trailing)
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(animeNode.node.startSeasonFormatted())
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        HStack(spacing: 4){
                            Text(animeNode.node.title)
                        }
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.bottom, 5)
                        
                        HStack(spacing: 4) {
                            let maxTags = 2
                            ForEach(animeNode.node.genres.prefix(maxTags), id: \.name) { tag in
                                Text(tag.name)
                                    .font(.caption)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 2)
                                    .font(.body)
                                    .background(Color.accentColor)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(3)
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
                    ProgressView(value: Float(self.animeNode.record["episodes_seen"] as? Int ?? 0), total: Float(animeNode.node.num_episodes)) {
                        HStack(spacing: 4) {
                            Text("Score: \(animeNode.node.meanFormatted()) | Rank: \(animeNode.node.rankFormatted())")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Spacer()

                            Text("Episodes:")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Text("\(self.animeNode.record["episodes_seen"] as? Int ?? 0)")
                                .foregroundColor(.secondary)
                                .font(.caption)
//                                .border(.orange)
                                                    
                            Text(verbatim: "/ \(animeNode.node.num_episodes.description)")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .progressViewStyle(.linear)
                    
                    Label("Next episode: \(Date().formatted(date: .abbreviated, time: .shortened))", systemImage: "clock")
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


