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
    
    var data: [WeebItem]
    
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
        
        ForEach(data, id: \.id) { item in
            Button {
                
                // navigate to detail
                if item is Anime {
                    appState.homePath.append(DetailDestination.anime(item.id))
                }
                else if item is Manga {
                    appState.homePath.append(DetailDestination.manga(item.id))
                }
            } label: {
                WeebCell(item: item)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.ui.background)

        }
        .onDelete(perform: delete)


//        }
//        .listStyle(.plain)
    }
    
    func delete(at offsets: IndexSet) {
        let index = offsets[offsets.startIndex]
        let item = animeViewModel.selectedAnimeData[index]
        
        Task {
            await animeViewModel.deleteProgress(item: item)
        }
    }
}

struct WatchList_Previews: PreviewProvider {
    static var previews: some View {
        WatchList(data: SampleData.sampleData)
            .environmentObject(
                AnimeViewModel(
                    animeRepository: AnimeRepository(animeData: SampleData.sampleData)
                )
            )
    }
}
