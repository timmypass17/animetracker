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
            DetailPoster(animeNode: animeNode)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(animeNode.node.startSeasonFormatted())
                        .foregroundColor(.white.opacity(0.6))
                }

                Text(animeNode.node.title)
                    .font(.system(size: 24))
                
                Text(animeNode.node.alternative_titles.ja)
                    .foregroundColor(.white.opacity(0.6))
                
                HStack {
                    Label("\(animeNode.node.num_episodes) Episodes", systemImage: "tv")
                        .font(.system(size: 12))
                    
                    Circle()
                        .frame(width: 3 )
                    
                    Label("\(animeNode.node.average_episode_duration / 60) min", systemImage: "clock")
                        .font(.system(size: 12))
                }
                .padding(.top, 8)
                                
                HStack {
                    VStack(spacing: 2) {
                        Text("Score".uppercased())
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 1)
                            .background(RoundedRectangle(cornerRadius: 4).fill(.blue))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star")
                            Text(animeNode.node.meanFormatted())
                                .font(.system(size: 16))
                        }
                    }
                    
                    VStack(spacing: 2) {
                        Text("Rank".uppercased())
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 1)
                            .background(RoundedRectangle(cornerRadius: 4).fill(.blue))
                        
                        HStack(spacing: 0) {
                            Image(systemName: "number")
                            Text(animeNode.node.rankFormatted())
                                .font(.system(size: 16))
                        }
                    }
                    VStack(spacing: 2) {
                        Text("Popularity".uppercased())
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 1)
                            .background(RoundedRectangle(cornerRadius: 4).fill(.blue))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.2")
                            Text("\(animeNode.node.num_list_users)")
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
