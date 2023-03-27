//
//  RequestList.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 3/3/23.
//

import SwiftUI

struct FriendRequestView: View {
    @Binding var users: [(User, Friendship)]

    var body: some View {
        VStack(alignment: .leading) {
            Color.ui.background
            ForEach(users, id: \.1.recordName) { user, status in
                FriendRequestCell(user: user, status: status)
            }
        }
    }
}

struct AcceptList_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequestView(users: .constant([]))
    }
}
