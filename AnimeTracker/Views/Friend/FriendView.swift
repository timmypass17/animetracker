//
//  FriendView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/21/23.
//

import SwiftUI

struct FriendView: View {
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var appState: AppState
    
    var name: String {
        let firstName = appState.user?.firstName ?? ""
        let lastName = appState.user?.lastName ?? ""
        return "\(firstName) \(lastName)"
    }
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Your name is: \(name)")
                    .foregroundColor(.secondary)
                    .padding(.leading)
                AddFriendList(users: $friendViewModel.userSearchResult)
                FriendRequestView(users: $friendViewModel.pendingRequest)
                FriendList()
            }
        }
        .navigationTitle("Friends")
        .frame(maxWidth: .infinity)
        .background(Color.ui.background)
        .searchable(text: $friendViewModel.searchText, prompt: "Search via name (ex. John Smith)")
        .onSubmit(of: .search) {
            Task {
                try await friendViewModel.fetchUsers(startingWith: friendViewModel.searchText)
            }
        }
        .onReceive(friendViewModel.$searchText.debounce(for: 0.3, scheduler: RunLoop.main)
        ) { _ in
            // Debounce. Fetch api calls after 0.5 seconds of not typing.
            Task {
                try await friendViewModel.fetchUsers(startingWith: friendViewModel.searchText)
            }
        }
        .onAppear {
            Task {
                friendViewModel.pendingRequest = await friendViewModel.fetchPendingFriendshipRequests()
                await friendViewModel.fetchFriends()
                print("Pending: \(friendViewModel.pendingRequest.count)")
                print("Friends: \(friendViewModel.friends.count)")
            }
        }
        .refreshable {
            print("Refreshing")
            friendViewModel.pendingRequest = await friendViewModel.fetchPendingFriendshipRequests()
            await friendViewModel.fetchFriends()
            // Fetch any incoming requests
        }
    }
    
}

struct FriendView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FriendView()
                .environmentObject(FriendViewModel(animeRepository: AnimeRepository(), appState: AppState()))
                .environmentObject(AppState())
        }
    }
}
