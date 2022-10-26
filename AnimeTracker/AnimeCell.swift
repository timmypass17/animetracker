//
//  AnimeCell.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import SwiftUI

struct AnimeCell: View {
    @Binding var anime: Anime
    @State var progress = 0.5
    @State var text = ""

    
    var body: some View {
        VStack(spacing: 0) {

            HStack(alignment: .imageTitleAlignmentGuide, spacing: 0) {
                AsyncImage(url: URL(string: anime.posterUrl)) { image in
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
                
                VStack(alignment: .leading, spacing:10) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Fall 2007")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Text(anime.title)

                        GenreTagView(genre: anime.genre)

                    }
                                        
                    ProgressView(value: 96, total: 456) {
                        HStack {
                            Text("21 seasons | Finished")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Spacer()

                            Text("Episodes:")
                                .foregroundColor(.secondary)
                                .font(.caption)
                                                    
                            TextField("0", text: $text)
                                .fixedSize()
                                .font(.caption)
                                                    
                            Text("/ \(anime.episodes.description)")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Label("Next episode: \(Date().formatted(date: .abbreviated, time: .shortened))", systemImage: "clock")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                }

                Spacer()
            }
            .padding(.bottom)
            
            Divider()
        }
        
    }
}

struct AnimeCell_Previews: PreviewProvider {
    static var previews: some View {
        AnimeCell(anime: .constant(Anime.sampleAnimes[0]))
//            .border(.blue)
    }
}

extension VerticalAlignment {
    private struct ImageTitleAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.top]
        }
    }
    
    static let imageTitleAlignmentGuide = VerticalAlignment(
        ImageTitleAlignment.self
    )
}
