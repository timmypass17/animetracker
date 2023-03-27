//
//  AddFriendView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/27/23.
//

import SwiftUI

struct AddFriendView: View {
    @EnvironmentObject var friendViewModel: FriendViewModel
    @EnvironmentObject var appState: AppState
    @State var searchText: String = ""
    
    var name: String {
        let firstName = appState.user?.firstName ?? ""
        let lastName = appState.user?.lastName ?? ""
        return "\(firstName) \(lastName)"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                Text("Your name is: \(name)")
                    .foregroundColor(.secondary)

                FriendList()
            }
        }
        .navigationTitle("Add Friend")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ui.background)
        .searchable(text: $friendViewModel.searchText) {
            Text("\(friendViewModel.searchText)")
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
                .environmentObject(AppState())
        }
    }
}
