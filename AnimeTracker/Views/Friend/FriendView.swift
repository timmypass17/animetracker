//
//  FriendView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/21/23.
//

import SwiftUI

struct FriendView: View {
    @EnvironmentObject var friendViewModel: FriendViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                RequestList(users: $friendViewModel.pendingRequest)
                FriendList(users: $friendViewModel.friends)
            }
        }
        .navigationTitle("Profile")
        .background(Color.ui.background)
        .searchable(
            text: $friendViewModel.searchText,
            prompt: "Filter friend by name"
        ) {
            FriendList(users: $friendViewModel.userSearchResult)
        }
        .toolbar {
            ToolbarItem {
                Button(action: { friendViewModel.isShowingAddFriendSheet.toggle() }) {
                    Image(systemName: "person.badge.plus") // plus.square
                }
            }
        }
        .sheet(isPresented: $friendViewModel.isShowingAddFriendSheet) {
            NavigationStack {
                AddFriendView()
            }
        }
        .onAppear {
            Task {
                friendViewModel.pendingRequest = await friendViewModel.fetchPendingFriendshipRequests()
                await friendViewModel.fetchFriends()
            }
        }
    }
    
}

struct FriendView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FriendView()
                .environmentObject(FriendViewModel(animeRepository: AnimeRepository(), appState: AppState()))
        }
    }
}
