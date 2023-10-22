//
//  FriendRequestViewModel.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/27/23.
//

import Foundation

@MainActor
class FriendRequestCellViewModel: ObservableObject, Identifiable {
    @Published var profile: Profile
    @Published var friendshipRequest: FriendRequest

    var id: String {
        return "profile.id + friendshipRequest.id"
    }
    
    init(profile: Profile, friendshipRequest: FriendRequest) {
        self.profile = profile
        self.friendshipRequest = friendshipRequest
    }
    
}
