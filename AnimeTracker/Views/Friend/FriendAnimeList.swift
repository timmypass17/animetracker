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
        VStack {
            ForEach(animes, id: \.node.id) { anime in
                HStack {
                    Text(anime.node.getTitle())
                    
                    Spacer()
                    
                    Text("\(anime.record.seen) / \(anime.node.getNumEpisodesOrChapters())")
                }
            }
        }
        .onAppear {
            Task {
                animes = await friendViewModel.getAnimeData(user: user)
                print(animes.map{ $0.node.title })
            }
        }
    }
}

struct FriendAnimeList_Previews: PreviewProvider {
    static var previews: some View {
        FriendAnimeList(animes: AnimeCollection.sampleData, user: User.sampleUsers[0])
    }
}
