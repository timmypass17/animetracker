//
//  ProfileViewModel.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/20/23.
//

import Foundation
import CloudKit
import SwiftUI
import PhotosUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: Profile = Profile.sampleProfiles[0]
    @Published var userAnimeMangaList: [WeebItem] = []
    @Published var searchText = ""
    @Published var selectedTab: ProfileTab = .friends
    
    @Published private(set) var imageState: ImageState = .empty
    @Published var imageSelection: PhotosPickerItem? {
        // set imageSelect to .empty if image is nil, other wise, start loading the image
        // didSet is called whenever the property imageSelection is assigned a new value. (true even if new value is same as old value)
        didSet {
            if let imageSelection {
                let progress = loadTransferable(from: imageSelection)
                imageState = .loading(progress)
            } else {
                imageState = .empty
            }
        }
    }
    @Published var imageData: Data?
    private lazy var container: CKContainer = CKContainer.default()
    private lazy var database: CKDatabase = container.publicCloudDatabase // TOOD: Change back to private
    
    enum ImageState {
        case empty, loading(Foundation.Progress), success(Data), failure(Error)
    }
    
    var animeRepository: AnimeRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(animeRepository: AnimeRepository) {
        self.animeRepository = animeRepository
        
        self.animeRepository.$animeData
            .assign(to: \.userAnimeMangaList, on: self)
            .store(in: &cancellables)
        
        self.animeRepository.$profile
            .assign(to: \.profile, on: self)
            .store(in: &cancellables)
    }
    
    // Use modifying records to handle invite and creating friendship records atommically
    
    
    
    func sendFriendRequest() async {
        do {
            let userID = try await container.userRecordID()
            let result = await animeRepository.sendFriendRequest(senderID: userID.recordName, receiverID: self.searchText)
            switch result {
            case .success(let friendRequest):
                // Handle successfully sending friend request
                break
            case .failure(let error):
                // Handle fail to send friend request (e.g. request exists already, something went wrong in cloudkit)
                break
            }
        } catch {
            print("Erroing sending friend request: \(error)")
        }
    }
    
    func getNumAnime() -> Int {
        return userAnimeMangaList.filter { $0.getWeebItemType() == .anime }.count
    }
    
    func getNumManga() -> Int {
        return userAnimeMangaList.filter { $0.getWeebItemType() == .manga }.count
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Foundation.Progress {
        return imageSelection.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else { return }
                switch result {
                case .success(let data?):
//                    self.imageData = data
                    // Handle the success case with the iamge.
                    self.imageState = .success(data)
                    
                    // Save image to disk and create url.
                    do {
                        let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                        let imageURL = documentsDirectory.appendingPathComponent("animeProfilePicture.jpg")
                        try data.write(to: imageURL)
                        print("file saved")
                        
                        self.profile.profileImage = CKAsset(fileURL: imageURL)
                        
                        // Save imageurl to cloudkit
                        Task {
                            await self.animeRepository.saveProfile(newProfile: self.profile)
                        }
                        
//                        // Clean up directory?
//                        try FileManager.default.removeItem(at: imageURL)
//                        print("remove file")
                    } catch {
                        print("Error saving image to disk: \(error)")
                    }
                    
                    print("loaded image")
                case.success(nil):
                    // Handle the success case with an empty value.
                    self.imageState = .empty
                case .failure(let error):
                    // Handle the failure case with the provided error.
                    print("Error loading image: \(error)")
                    self.imageState = .failure(error)
                }
            }
        }
    }
    
}
