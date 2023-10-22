//
//  FriendRequestCell.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/27/23.
//

import SwiftUI

struct FriendRequestCell: View {
    var friendRequestCellViewModel: FriendRequestCellViewModel
    var onAccept: (FriendRequestCellViewModel) async -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: friendRequestCellViewModel.profile.profileImage?.fileURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    Circle()
                        .fill(.regularMaterial)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            Text("\(friendRequestCellViewModel.profile.username)")
            
            Spacer()
            
            Button {
                print("Remove friend")
            } label: {
                Image(systemName: "xmark")
            }


            Button {
                print("Accept friend request")
                Task {
                    await onAccept(friendRequestCellViewModel)
                }
            } label: {
                Image(systemName: "checkmark")
                    .symbolRenderingMode(.multicolor)
            }
            
            
        }
        
    }
}

struct FriendRequestCell_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequestCell(
            friendRequestCellViewModel: FriendRequestCellViewModel(
                profile: Profile.sampleProfiles[0],
                friendshipRequest: FriendRequest.sampleFriendRequests[0]
            ),
            onAccept: { _ in
                
            }
        )
    }
}
