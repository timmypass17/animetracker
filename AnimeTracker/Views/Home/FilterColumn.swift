//
//  FilterColumn.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/11/23.
//

import SwiftUI

struct FilterColumn: View {
    @EnvironmentObject var animeViewModel: AnimeViewModel
    
    var body: some View {
        ForEach($animeViewModel.filterResults, id: \.node.id) { $animeNode in
            AnimeCell(animeNode: $animeNode)
                .listRowSeparator(.hidden) // remove default separator
        }
    }
}

struct FilterColumn_Previews: PreviewProvider {
    static var previews: some View {
        FilterColumn()
            .environmentObject(AnimeViewModel(animeRepository: AnimeRepository()))
    }
}
