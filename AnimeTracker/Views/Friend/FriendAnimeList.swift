//
//  FriendAnimeList.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 3/3/23.
//

import SwiftUI

struct FriendAnimeList: View {
    @EnvironmentObject var friendViewModel: FriendViewModel
    @State var animes: [AnimeNode] = []
    var user: User
    
    var body: some View {
        ZStack {
            Color.ui.background
                .ignoresSafeArea()


            ScrollView {
                VStack {
                    AnimeList(animeData: $animes)
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(Text("\(user.firstName)'s Watch List"))
            .onAppear {
                Task {
                    animes = await friendViewModel.getAnimeData(user: user)
                    print(animes.map{ $0.node.title })
                }
            }
        }
//        .background(Color.ui.background)
    }
}

struct FriendAnimeList_Previews: PreviewProvider {
    static var previews: some View {
        FriendAnimeList(animes: AnimeCollection.sampleData, user: User.sampleUsers[0])
            .environmentObject(FriendViewModel(animeRepository: AnimeRepository(), appState: AppState()))
    }
}
