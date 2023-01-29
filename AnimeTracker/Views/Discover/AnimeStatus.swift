//
//  AnimeStatus.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/22/23.
//

import SwiftUI

struct AnimeStatus: View {
    let animeNode: AnimeNode
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Circle()
                .fill(selectColor)
                .frame(width: 5)
                .padding(.top, 2)
            Text(animeNode.node.statusFormatted())
                .font(.system(size: 10))
        }
        .foregroundColor(Color.ui.tag_text)
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .background{
            RoundedRectangle(cornerRadius: 2)
                .fill(.regularMaterial)
        }
    }
    
    var selectColor: Color {
        switch animeNode.node.status {
            
        case "currently_airing":
            return .yellow
            
        case "finished_airing":
            return .green
        default:
            return .red
            
        }
    }
}

struct AnimeStatus_Previews: PreviewProvider {
    static var previews: some View {
        AnimeStatus(animeNode: AnimeCollection.sampleData[0])
    }
}
