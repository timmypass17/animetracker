//
//  RequestCell.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 3/9/23.
//

import SwiftUI

struct AddFriendCell: View {
    @EnvironmentObject var friendViewModel: FriendViewModel
    @State var requestSent = false
    let user: User
    
    var isFriend: Bool {
        return friendViewModel.friends.contains(where: { $0.userID.recordID.recordName == user.userID.recordID.recordName })
    }
    
    var buttonText: String {
        if isFriend { return "Friend" }
        if requestSent { return "Request Sent" }
        return "Add"
    }
    
    var body: some View {
        HStack {
            HStack {
                Circle()
                    .frame(width: 40)
                
                VStack(alignment: .leading) {
                    Text("\(user.firstName) \(user.lastName)")
                }
                
                Spacer()
            }
            
            Button(buttonText) {
                requestSent = true
                Task {
                    await friendViewModel.followButtonTapped(userToFollow: user)
                }
            }
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.vertical, 4)
            .padding(.horizontal)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(Color.ui.tag)
            }
            .disabled(isFriend || requestSent)
            
            
        }
        .padding()
    }
}

struct RequestCell_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendCell(user: User.sampleUsers[0])
            .environmentObject(FriendViewModel(animeRepository: AnimeRepository(), appState: AppState()))
    }
}
