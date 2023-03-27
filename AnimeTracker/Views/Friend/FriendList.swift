//
//  FriendList.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/27/23.
//

import SwiftUI

struct FriendList: View {
    @EnvironmentObject var friendViewModel: FriendViewModel

    var body: some View {
        ForEach(friendViewModel.friends) { friend in
            FriendCell(user: friend)
        }
    }
}

struct FriendList_Previews: PreviewProvider {
    static var previews: some View {
        FriendList()
            .environmentObject(FriendViewModel(animeRepository: AnimeRepository(), appState: AppState()))
    }
}
