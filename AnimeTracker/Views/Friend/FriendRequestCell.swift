//
//  PersonCell.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/21/23.
//

import SwiftUI

struct FriendRequestCell: View {
    @EnvironmentObject var friendViewModel: FriendViewModel
    let user: User
    let status: Friendship
    
    var body: some View {
        HStack {
            HStack {
                Circle()
                    .frame(width: 40)
                
                VStack(alignment: .leading) {
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.headline)
                }
                
                Spacer()
            }
            
            AcceptButton(friend: user, status: status, acceptButtonTapped: friendViewModel.acceptButtonTapped)
                .padding(.trailing)
            
            Button {
                // Handle decline
            } label: {
                Image(systemName: "xmark")
            }
            .foregroundColor(.secondary)
            
            
        }
        .padding()
        .background(Color.ui.background)
    }
}

struct AcceptCell_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequestCell(
            user: User.sampleUsers[1],
            status: Friendship.sampleFriendShipRequest
        )
        .environmentObject(FriendViewModel(animeRepository: AnimeRepository(), appState: AppState()))
            .previewLayout(.sizeThatFits)
    }
}

struct AcceptButton: View {
    let friend: User
    var status: Friendship
    var acceptButtonTapped: (User, Friendship) async -> Void

    var body: some View {
        Button {
            Task {
                await acceptButtonTapped(friend, status)
            }
        } label: {
            Image(systemName: "checkmark")
                .foregroundColor(.secondary)
        }
        .foregroundColor(.secondary)

    }
    
}
