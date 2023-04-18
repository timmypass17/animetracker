//
//  HomeColumn.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/9/23.
//

import SwiftUI

struct WatchList: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var animeViewModel: AnimeViewModel

    var body: some View {
//        VStack(spacing: 0) {
//            ForEach(animeViewModel.userAnimeMangaList, id: \.id) { item in
//                NavigationLink {
//                    AnimeDetail(id: item.id, type: item is Anime ? .anime : .manga)
//                } label: {
//                    WeebCell(item: item)
//                }
//                .buttonStyle(.plain)
//
//                Divider()
//            }
//        }
        
//        List(animeViewModel.userAnimeMangaList, id: \.id) { item in
        ForEach(animeViewModel.userAnimeMangaList, id: \.id) { item in
            //            NavigationLink {
            //                AnimeDetail(id: item.id, type: item is Anime ? .anime : .manga)
            //            } label: {
            //                WeebCell(item: item)
            //            }
            
            Button {
                // navigate to detail
                appState.path.append(item.id)
            } label: {
                WeebCell(item: item)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.ui.background)


            
            
        }

//        }
//        .listStyle(.plain)
    }
}

struct WatchList_Previews: PreviewProvider {
    static var previews: some View {
        WatchList()
            .environmentObject(
                AnimeViewModel(
                    animeRepository: AnimeRepository(animeData: SampleData.sampleData), appState: AppState()
                )
            )
    }
}
