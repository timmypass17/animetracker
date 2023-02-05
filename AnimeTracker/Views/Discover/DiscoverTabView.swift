//
//  DiscoverTabView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/11/23.
//

import SwiftUI

struct DiscoverTabView: View {
    @EnvironmentObject var discoverViewModel: DiscoverViewModel

    var body: some View {
        Picker("View Mode", selection: $discoverViewModel.selectedAnimeType) {
            ForEach(AnimeType.allCases) { mode in
                Text(mode.rawValue.capitalized)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct DiscoverTabView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverTabView()
            .environmentObject(AnimeViewModel(animeRepository: AnimeRepository()))
    }
}
