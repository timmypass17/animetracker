//
//  SearchResults.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/18/23.
//

import SwiftUI

struct SearchList: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var animeViewModel: AnimeViewModel
    
    var data: [WeebItem]
    @Binding var path: NavigationPath
    var showDivider = false // divider ruins view when used in list
    
    var body: some View {
        ForEach(data, id: \.id) { item in
            Button {
                if item is Anime {
                    path.append(DetailDestination.anime(item.id))
                }
                else if item is Manga {
                    path.append(DetailDestination.manga(item.id))
                }
            } label: {
                WeebCell(item: item)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.ui.background)
            
            if showDivider {
                Divider()
            }
        }
    }
    
}
//
//struct WatchList_Previews: PreviewProvider {
//    static var previews: some View {
//        WatchList(data: SampleData.sampleData)
//            .environmentObject(
//                AnimeViewModel(
//                    animeRepository: AnimeRepository(animeData: SampleData.sampleData), appState: AppState()
//                )
//            )
//    }
//}
