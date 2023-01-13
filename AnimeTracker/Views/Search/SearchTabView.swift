//
//  SearchTabView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/11/23.
//

import SwiftUI

struct SearchTabView: View {
    @EnvironmentObject var animeViewModel: AnimeViewModel

    var body: some View {
        Picker("View Mode", selection: $animeViewModel.selectedSearchMode) {
            ForEach(SearchMode.allCases) { mode in
                Text(mode.rawValue.capitalized)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct SearchTabView_Previews: PreviewProvider {
    static var previews: some View {
        SearchTabView()
            .environmentObject(AnimeViewModel())
    }
}
