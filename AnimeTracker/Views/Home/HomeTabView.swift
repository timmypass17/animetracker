//
//  HomeTabView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/11/23.
//

import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var animeViewModel: AnimeViewModel

    var body: some View {
        Picker("View Mode", selection: $animeViewModel.selectedViewMode) {
            ForEach(ViewMode.allCases) { mode in
                Text(mode.rawValue.capitalized.replacingOccurrences(of: "_", with: " "))
            }
        }
        .pickerStyle(.segmented)
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
            .environmentObject(AnimeViewModel())
    }
}
