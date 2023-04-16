//
//  AnimeStatus.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/22/23.
//

import SwiftUI

struct AnimeStatus: View {
    let animeNode: WeebItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Circle()
                .fill(animeNode.getAiringStatusColor())
                .frame(width: 5)
                .padding(.top, 2)
            
            Text(animeNode.getStatus())
                .font(.system(size: 10))
                .lineLimit(1)
                .foregroundColor(Color.ui.textColor)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .background{
            RoundedRectangle(cornerRadius: 2)
                .fill(.regularMaterial)
        }
    }
}

struct AnimeStatus_Previews: PreviewProvider {
    static var previews: some View {
        AnimeStatus(animeNode: SampleData.sampleData[0])
    }
}
