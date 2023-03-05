//
//  AddFriendView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/27/23.
//

import SwiftUI

struct AddFriendView: View {
    @EnvironmentObject var friendViewModel: FriendViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                FriendList(users: $friendViewModel.userSearchResult)
            }
        }
        .navigationTitle("Add Friend")
        .background(Color.ui.background)
        .searchable(
            text: $friendViewModel.searchText,
            prompt: "Search for other users by name"
        ) {
            FriendList(users: $friendViewModel.userSearchResult)
        }
        .onSubmit(of: .search) {
            Task {
                try await friendViewModel.fetchUsers(startingWith: friendViewModel.searchText)
            }
        }
        
    }
}

struct AddFriendView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddFriendView()
                .environmentObject(FriendViewModel(animeRepository: AnimeRepository(), appState: AppState()))
        }
    }
}
