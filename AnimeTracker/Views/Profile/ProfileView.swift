//
//  ProfileView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/20/23.
//

import SwiftUI
import PhotosUI

enum ProfileTab: String, CaseIterable, Identifiable {
    case watchlist, friends
    var id: Self { self }
}

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center) {
                
                CircularProfileImage()
                    .overlay(alignment: .bottomTrailing) {
                        PhotosPicker(selection: $profileViewModel.imageSelection, matching: .images, photoLibrary: .shared()) {
                            Image(systemName: "plus.circle.fill")
                                .symbolRenderingMode(.palette)
                                .font(.system(size: 25))
                                .foregroundStyle(.white, .blue)
                                .overlay {
                                    Circle()
                                        .stroke(Color.ui.background ,lineWidth: 3)
                                }
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.top, 30)

                
                // Name
                HStack(spacing: 4) {
                    Text(profileViewModel.profile.usernameString())
                        .fontWeight(.bold)
                    Text("#\(profileViewModel.profile.usernameDigits())")
                        .foregroundColor(.gray)
                }
                .font(.system(size: 18))
                .padding(.bottom)
                
                HStack(spacing: 40) {
                    VStack {
                        Text("20")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                        
                        Text("Following")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                    }
                    
                    VStack {
                        Text("\(profileViewModel.getNumAnime())")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                        Text("Anime")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                    }
                    
                    VStack {
                        Text("\(profileViewModel.getNumManga())")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                        
                        Text("Manga")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                    }
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                Picker("Profile Tab", selection: $profileViewModel.selectedTab) {
                    ForEach(ProfileTab.allCases) { mode in
                        Text(mode.rawValue.capitalized)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom)
                
                switch profileViewModel.selectedTab {
                case .watchlist:
                    SearchList(
                        data: profileViewModel.userAnimeMangaList,
                        path: $appState.profilePath,
                        showDivider: true
                    )
                case .friends:
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Add via username".uppercased())
                            .font(.system(size: 12))
                        
                        TextField("Username#0000", text: $profileViewModel.searchText)
                            .textFieldStyle(.roundedBorder)
                        
                        Text("Your username is \(profileViewModel.profile.usernameString())#\(profileViewModel.profile.usernameDigits())")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom)
                    
                    Button {
                        // Handle sending friend request
                        Task {
                            await profileViewModel.sendFriendRequest()
                        }
                    } label: {
                        Text("Send Friend Request")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(Color.accentColor)
                            .cornerRadius(4)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Pending - 6".uppercased())
                            .font(.system(size: 12))
                        
                        ForEach(1..<3) { i in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(.regularMaterial)
                                    .frame(width: 40, height: 40)
                                Text("Pending \(i)")
                                
                                Spacer()
                                
                                Image(systemName: "xmark")

                                Image(systemName: "checkmark")
                                    .symbolRenderingMode(.multicolor)

                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text("Friends - 7".uppercased())
                            .font(.system(size: 12))
                        
                        ForEach(1..<8) { i in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(.thinMaterial)
                                    .frame(width: 40, height: 40)
                                Text("Friend \(i)")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                }
                
                
                Spacer()
            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .background(Color.ui.background)
        .refreshable {
            // Handle fetching data
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
                .environmentObject(ProfileViewModel(animeRepository: AnimeRepository()))
        }
    }
}
