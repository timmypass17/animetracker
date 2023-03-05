//
//  PersonCell.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/21/23.
//

import SwiftUI

struct RequestCell: View {
    @EnvironmentObject var friendViewModel: FriendViewModel
    let user: User
    let status: Friendship
    
    var body: some View {
        HStack {
            HStack {
                Circle()
                    .frame(width: 60)
                
                VStack(alignment: .leading) {
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.headline)
                }
                
                Spacer()
            }
            
            AcceptButton(friend: user, status: status, acceptButtonTapped: friendViewModel.acceptButtonTapped)
            
            Button("Decline") {
            }
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.vertical, 4)
            .frame(width: 80)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(Color.ui.tag)
            }
            
            
        }
        .padding()
        .background(Color.ui.background)
    }
}

struct RequestCell_Previews: PreviewProvider {
    static var previews: some View {
        RequestCell(
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
        Button("Accept") {
            Task {
                await acceptButtonTapped(friend, status)
            }
        }
        .font(.subheadline)
        .foregroundColor(.white)
        .padding(.vertical, 4)
        .frame(width: 80)
        .background {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(.accentColor)
        }
    }
    
}
