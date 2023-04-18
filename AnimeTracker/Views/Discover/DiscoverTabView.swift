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
            Text(AnimeType.anime.rawValue.capitalized)
                .tag(AnimeType.anime)

            Text(AnimeType.manga.rawValue.capitalized)
                .tag(AnimeType.manga)
        }
        .pickerStyle(.segmented)
    }
}

struct DiscoverTabView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverTabView()
            .environmentObject(AnimeViewModel(animeRepository: AnimeRepository(), appState: AppState()))
    }
}
