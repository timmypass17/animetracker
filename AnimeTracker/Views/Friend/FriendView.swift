//
//  FriendView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/21/23.
//

import SwiftUI

struct FriendView: View {
    @EnvironmentObject var friendViewModel: FriendViewModel

    var body: some View {
        ScrollView {
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
        }
        .navigationTitle("Profile")
        .background(Color.ui.background)
    }
}

struct FriendView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FriendView()
                .environmentObject(FriendViewModel())
        }
    }
}
