//
//  GenreTagView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/24/22.
//

import SwiftUI
import SwiftUI

struct GenreTagView: View {
    var genre: [String]

    @State private var totalHeight
          = CGFloat.zero       // << variant for ScrollView/List
    //    = CGFloat.infinity   // << variant for VStack

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)// << variant for ScrollView/List
        //.frame(maxHeight: totalHeight) // << variant for VStack
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.genre, id: \.self) { tag in
                self.item(for: tag)
                    .padding([.trailing, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == self.genre.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == self.genre.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func item(for text: String) -> some View {
        HStack {
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 2)
        .font(.body)
        .background(Color.accentColor)
        .foregroundColor(Color.white)
        .cornerRadius(3)
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

//struct GenreTagView_Previews: PreviewProvider {
//    static var previews: some View {
//        GenreTagView(genre: AnimeCollection.sampleData[0].node.genres.map{ $0.name })
//    }
//}
