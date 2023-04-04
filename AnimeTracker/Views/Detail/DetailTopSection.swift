//
//  DetailTopSection.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct DetailTopSection: View {
    let animeNode: AnimeNode
    @State var isTitleExpanded = false
    @State var isJapaneseTitleExpanded = false
    
    var body: some View {
        HStack(alignment: .top) {
            DetailPoster(poster: animeNode.node.main_picture, height: 200)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(animeNode.node.animeCellHeader())
                    .foregroundColor(Color.ui.textColor.opacity(0.6))
                
                Text(animeNode.node.getTitle())
                    .font(.system(size: 24))
                    .foregroundColor(Color.ui.textColor)
                    .lineLimit(isTitleExpanded ? nil : 2)
//                    .onTapGesture {
//                        isTitleExpanded.toggle()
//                    }
//
                Text(animeNode.node.getJapaneseTitle())
                    .foregroundColor(Color.ui.textColor.opacity(0.6))
                    .lineLimit(isJapaneseTitleExpanded ? nil : 2)
//                    .onTapGesture {
//                        isJapaneseTitleExpanded.toggle()
//                    }

                if animeNode.node.animeType == .anime {
                    HStack {
                        Label("\(animeNode.node.getNumEpisodesOrChapters()) \(animeNode.node.getEpisodeOrChapter())",
                              systemImage: "tv"
                        )
                        .font(.system(size: 12))
                        .foregroundColor(Color.ui.textColor)
                        
                        
                        Circle()
                            .frame(width: 3)
                        
                        Label("\(animeNode.node.getEpisodeMinutes())", systemImage: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(Color.ui.textColor)
                    }
                    .padding(.top, 8)
                } else {
                    HStack {
                        Label("\(animeNode.node.getNumChapters()) Chapters", systemImage: "book")
                            .font(.system(size: 12))
                            .foregroundColor(Color.ui.textColor)
                        
                        Circle()
                            .frame(width: 3)
                        
                        Label("\(animeNode.node.getNumVolume()) Volumes",
                              systemImage: "books.vertical"
                        )
                        .font(.system(size: 12))
                        .foregroundColor(Color.ui.textColor)
                        
                    }
                    .padding(.top, 8)
                }
                                
                HStack {
                    VStack(spacing: 2) {
                        Text("Score".uppercased())
                            .fontWeight(.semibold)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 5)
                            .background(RoundedRectangle(cornerRadius: 2).fill(.blue))
                        
                        HStack(spacing: 4) {
                            Text(animeNode.node.getMean())
                                .font(.system(size: 16))
                                .foregroundColor(Color.ui.textColor)
                        }
                    }
                    
                    VStack(spacing: 2) {
                        Text("Rank".uppercased())
                            .fontWeight(.semibold)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 5)
                            .background(RoundedRectangle(cornerRadius: 2).fill(.blue))
                        
                        HStack(spacing: 0) {
                            if animeNode.node.rank != nil {
                                Image(systemName: "number")
                                    .foregroundColor(Color.ui.textColor)
                            }
                            
                            Text(animeNode.node.getRank())
                                .font(.system(size: 16))
                                .foregroundColor(Color.ui.textColor)
                        }
                    }
                    VStack(spacing: 2) {
                        Text("Popularity".uppercased())
                            .fontWeight(.semibold)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 5)
                            .background(RoundedRectangle(cornerRadius: 2).fill(.blue))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.2")
                                .foregroundColor(Color.ui.textColor)

                            Text("\(animeNode.node.getNumListUser())")
                                .font(.system(size: 16))
                                .foregroundColor(Color.ui.textColor)
                        }
                    }
                    
                }
                .font(.caption)
                .padding(.top)
            
                
            }
            .foregroundColor(.white)
            
            Spacer()
        }
    }
}

struct DetailTopSection_Previews: PreviewProvider {
    static var previews: some View {
        DetailTopSection(animeNode: AnimeCollection.sampleData[0])
    }
}
