//
//  FriendList.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/27/23.
//

import SwiftUI

struct FriendList: View {
    @EnvironmentObject var friendViewModel: FriendViewModel
    @Binding var users: [User]

    var body: some View {
        ForEach(users) { friend in
            FriendCell(user: friend)
        }
    }
}

struct FriendList_Previews: PreviewProvider {
    static var previews: some View {
        FriendList(users: .constant(User.sampleUsers))
    }
}
