//
//  HomeTabView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/11/23.
//

import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel

    var body: some View {
        Picker("View Mode", selection: $homeViewModel.selectedViewMode) {
            ForEach(ViewMode.allCases) { mode in
                Text(mode.rawValue.capitalized)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
            .environmentObject(HomeViewModel())
    }
}
