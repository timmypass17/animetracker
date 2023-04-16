//
//  DetailTopSection.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct DetailTopSection: View {
    @State var isTitleExpanded = false
    @State var isJapaneseTitleExpanded = false
    let item: WeebItem?
    
    var body: some View {
        HStack(alignment: .top) {
            DetailPoster(poster: item?.main_picture, width: 120, height: 200)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(item?.getStartSeasonAndYear() ?? .placeholder(length: 10))
                    .foregroundColor(Color.ui.textColor.opacity(0.6))
                
                Text(item?.getTitle() ?? .placeholder(length: 15))
                    .font(.system(size: 24))
                    .foregroundColor(Color.ui.textColor)
                    .lineLimit(isTitleExpanded ? nil : 2)
//                    .onTapGesture {
//                        isTitleExpanded.toggle()
//                    }

                Text(item?.getJapaneseTitle() ?? .placeholder(length: 15))
                    .foregroundColor(Color.ui.textColor.opacity(0.6))
                    .lineLimit(isJapaneseTitleExpanded ? nil : 2)
//                    .onTapGesture {
//                        isJapaneseTitleExpanded.toggle()
//                    }
                

                if let anime = item as? Anime {
                    HStack {
                        Label("\(anime.getNumEpisodes()) Episodes",
                              systemImage: "tv"
                        )
                        .font(.system(size: 12))
                        .foregroundColor(Color.ui.textColor)
                        
                        Circle()
                            .frame(width: 3)
                        
                        Label("\(anime.getAverageEpisodeDuration())", systemImage: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(Color.ui.textColor)
                    }
                    .padding(.top, 8)
                }
                else if let manga = item as? Manga {
                    HStack {
                        Label("\(manga.getNumChapters()) Chapters", systemImage: "book")
                            .font(.system(size: 12))
                            .foregroundColor(Color.ui.textColor)
                        
                        Circle()
                            .frame(width: 3)
                        
                        Label("\(manga.getNumVolumes()) Volumes",
                              systemImage: "books.vertical"
                        )
                        .font(.system(size: 12))
                        .foregroundColor(Color.ui.textColor)
                        
                    }
                    .padding(.top, 8)
                } else {
                    Text(verbatim: .placeholder(length: 20))
                }
                                
                HStack {
                    VStack(spacing: 2) {
                        Text("Score".uppercased())
                            .fontWeight(.semibold)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 5)
                            .background(RoundedRectangle(cornerRadius: 2).fill(.blue))
                            .unredacted()
                        
                        HStack(spacing: 4) {
                            Text(item?.getMean() ??  .placeholder(length: 4))
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
                            .unredacted()
                        
                        HStack(spacing: 0) {
                            Image(systemName: "number")
                                .foregroundColor(Color.ui.textColor)
                            
                            Text(item?.getRank() ??  .placeholder(length: 4))
                                .font(.system(size: 16))
                                .foregroundColor(Color.ui.textColor)
                        }
//                        .redacted(reason: item == nil ? .placeholder : [])
                    }
                    
                    VStack(spacing: 2) {
                        Text("Popularity".uppercased())
                            .fontWeight(.semibold)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 5)
                            .background(RoundedRectangle(cornerRadius: 2).fill(.blue))
                            .unredacted()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.2")
                                .foregroundColor(Color.ui.textColor)

                            Text("\(item?.getNumListUser() ??  .placeholder(length: 5))")
                                .font(.system(size: 16))
                                .foregroundColor(Color.ui.textColor)
                        }
                    }
//                    .redacted(reason: item == nil ? .placeholder : [])
                }
                .font(.caption)
                .padding(.top)
            }
            .foregroundColor(.white)
            
            Spacer()
        }
        .redacted(reason: item == nil ? .placeholder : [])
    }
}

struct DetailTopSection_Previews: PreviewProvider {
    static var previews: some View {
        DetailTopSection(item: SampleData.sampleData[0])
        DetailTopSection(item: SampleData.sampleData[1])
        DetailTopSection(item: nil)
    }
}
