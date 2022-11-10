//
//  AnimeCell.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import SwiftUI

struct AnimeCell: View {
    @Binding var animeNode: AnimeNode
    @State var seen = ""
        
    var body: some View {
        VStack(spacing: 0) {

            HStack(alignment: .imageTitleAlignmentGuide, spacing: 0) {
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
                
                VStack(alignment: .leading, spacing:10) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(verbatim: "\(animeNode.node.start_season.season.capitalized) \(animeNode.node.start_season.year)")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Text(animeNode.node.title)

                        GenreTagView(genre: animeNode.node.genres.map{ $0.name })

                    }
                                        
                    ProgressView(value: Float(seen), total: Float(animeNode.node.num_episodes)) {
                        HStack(spacing: 4) {
                            Text("\(String(format: "Score: %.2f", animeNode.node.mean)) | Rank: \(animeNode.node.rank)")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Spacer()
//
//                            Label(anime.media_type.uppercased(), systemImage: "tv")
//                                .foregroundColor(.secondary)
//                                .font(.caption)
//
                            Text("Episodes")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            TextField("0", text: $seen)
                                .fixedSize()
                                .foregroundColor(.accentColor)
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
        
    }
}

struct AnimeCell_Previews: PreviewProvider {
    static var previews: some View {
        AnimeCell(animeNode: .constant(AnimeCollection.sampleData[0]))
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
