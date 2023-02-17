//
//  DetailTopSection.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct DetailTopSection: View {
    let animeNode: AnimeNode
    
    var body: some View {
        HStack(alignment: .top) {
            DetailPoster(poster: animeNode.node.main_picture, height: 200)

            
            VStack(alignment: .leading, spacing: 0) {
                Text(animeNode.node.animeCellHeader())
                    .foregroundColor(.white.opacity(0.6))
                
                Text(animeNode.node.getTitle())
                    .font(.system(size: 24))
                
                Text(animeNode.node.getJapaneseTitle())
                    .foregroundColor(.white.opacity(0.6))
                
                HStack {
                    Label("\(animeNode.node.getNumEpisodesOrChapters()) Episodes", systemImage: "tv")
                        .font(.system(size: 12))
                    
                    
                    Circle()
                        .frame(width: 3 )
                    
                    Label("\(animeNode.node.getEpisodeMinutes())", systemImage: "clock")
                        .font(.system(size: 12))
                }
                .padding(.top, 8)
                                
                HStack {
                    VStack(spacing: 2) {
                        Text("Score".uppercased())
                            .fontWeight(.semibold)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 5)
                            .background(RoundedRectangle(cornerRadius: 2).fill(.blue))
                        
                        HStack(spacing: 4) {
//                            if animeNode.node.mean != nil {
//                                Image(systemName: "star")
//                            }
                            
                            Text(animeNode.node.getMean())
                                .font(.system(size: 16))
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
                            }
                            
                            Text(animeNode.node.getRank())
                                .font(.system(size: 16))
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
                            Text("\(animeNode.node.getNumListUser())")
                                .font(.system(size: 16))
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
            .background(.black)
    }
}
