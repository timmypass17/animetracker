//
//  RequestList.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 3/9/23.
//

import SwiftUI

struct AddFriendList: View {
    @Binding var users: [User]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(users) { user in
                AddFriendCell(user: user)
            }
        }
    }
}

struct RequestList_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendList(users: .constant(User.sampleUsers))
    }
}
