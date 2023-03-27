//
//  PersonCell.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/21/23.
//

import SwiftUI

struct FriendCell: View {
    @EnvironmentObject var friendViewModel: FriendViewModel
    let user: User
    
    var body: some View {
        HStack {
            NavigationLink(destination: FriendAnimeList(user: user)) {
                
                HStack(alignment: .center) {
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                    
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
            .padding()
            .buttonStyle(.plain)
            
            Menu {
                Button("Remove Friend", role: .destructive) {
                    Task {
                        await friendViewModel.removeFriend(user)
                    }
                }
            } label: {
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                }
                .foregroundColor(.white)
            }
            .padding()
            
        }
        .background(Color.ui.background)
    }
}

struct FriendCell_Previews: PreviewProvider {
    static var previews: some View {
        FriendCell(user: User.sampleUsers[1])
            .environmentObject(FriendViewModel(animeRepository: AnimeRepository(), appState: AppState()))
            .previewLayout(.sizeThatFits)
    }
}

struct FriendButton: View {
    @Binding var friendStatus: Friendship.Status
    var user: User
    var followButtonTapped: (User) async -> Void

    var body: some View {
        Button(followText) {
            Task {
                await followButtonTapped(user)
            }
        }
        .font(.subheadline)
        .foregroundColor(.white)
        .padding(.vertical, 4)
        .frame(width: 80)
        .background {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(buttonColor)
        }
    }
    
    func handleFollow() {
        print("Clicked Follow")
    }
    
    var followText: String {
        switch friendStatus {
        case .accepted:
            return "Friends"
        case .pending:
            return "Pending"
        case .rejected:
            return "Follow"
        }
    }
    
    var buttonColor: Color {
        switch friendStatus {
        case .accepted:
            return Color.ui.tag
        case .pending:
            return Color.ui.tag
        case .rejected:
            return .accentColor
        }
    }
    
}
