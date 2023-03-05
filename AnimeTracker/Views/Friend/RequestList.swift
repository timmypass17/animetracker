//
//  RequestList.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 3/3/23.
//

import SwiftUI

struct RequestList: View {
    @Binding var users: [(User, Friendship)]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(users, id: \.1.recordName) { user, status in
                RequestCell(user: user, status: status)
            }
        }
    }
}

struct RequestList_Previews: PreviewProvider {
    static var previews: some View {
        RequestList(users: .constant([]))
    }
}
