//
//  CircularProfileImage.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/20/23.
//

import SwiftUI

struct CircularProfileImage: View {
    var body: some View {
        ProfileImage()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .background {
                Circle().fill(.gray)
            }
    }
}

struct ProfileImage: View {
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        // Case: User profile picture loaded
        if let profileImage = profileViewModel.profile.profileImage,
           let url = profileImage.fileURL {
            // Handle profile image
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                } else {
                    ProgressView()
                }
            }
        } else {
            // Case: Profile picture not taken
            switch profileViewModel.imageState {
            case .success(let data):
                if let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable().scaledToFill()
                }
            case .loading:
                ProgressView()
            case .empty:
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            case .failure:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
        }
    }
}

struct CircularProfileImage_Previews: PreviewProvider {
    static var previews: some View {
        CircularProfileImage()
            .environmentObject(ProfileViewModel(animeRepository: AnimeRepository()))
    }
}
