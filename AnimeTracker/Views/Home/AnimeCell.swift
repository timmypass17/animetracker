//
//  AnimeCell.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import SwiftUI

struct AnimeCell: View {
    @EnvironmentObject var animeViewModel: AnimeViewModel
    @Binding var animeNode: AnimeNode
    let width = 85.0
    let height = 135.0
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                if let poster = animeNode.node.main_picture {
                    DetailPoster(poster: poster, width: width, height: height)
                        .padding(.trailing)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text(animeNode.node.animeCellHeader())
                            
                            Spacer()
                            
//                            Image(systemName: "ellipsis")
                        }
                        .foregroundColor(.secondary)
                        .font(.caption)
                        
                        HStack(spacing: 4){
                            Text(animeNode.node.getTitle())
                        }
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.bottom, 5)
                        
                        GenreRow(animeNode: animeNode, maxTags: 2)
                            .font(.caption)
                            .scrollDisabled(true)
                        
                    }
                    
                    ProgressView(
                        value: Float(animeNode.record.seen),
                        total: Float(animeNode.node.getNumEpisodesOrChapters())
                    ) {
                        HStack(spacing: 4) {
                            AnimeStatus(animeNode: animeNode)
                                .font(.caption)
                            
                            Spacer()
                            Text("\(animeNode.node.getEpisodeOrChapter()):")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Text("\(animeNode.record.seen) /")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Text("\(animeNode.node.getNumEpisodesOrChapters() == 0 ? "?" : String(animeNode.node.getNumEpisodesOrChapters()))")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                        }
                        
                    }
                    .progressViewStyle(.linear)
                    
                    Label("Next \(animeNode.node.getEpisodeOrChapter()): \(animeNode.node.getBroadcast())", systemImage: "clock")
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
            .previewLayout(.sizeThatFits)
    }
}


