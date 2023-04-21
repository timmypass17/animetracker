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

@MainActor
class ProfileViewModel: ObservableObject {
    @Published private(set) var imageState: ImageState = .empty
    
    // set imageSelect to .empty if image is nil, other wise, start loading the image
    @Published var imageSelection: PhotosPickerItem? {
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
    
    enum ImageState {
        case empty, loading(Foundation.Progress), success(Data), failure(Error)
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Foundation.Progress {
        return imageSelection.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else { return }
                switch result {
                case .success(let data?):
                    self.imageData = data
                    self.imageState = .success(data)
                case.success(nil):
                    self.imageState = .empty
                case .failure(let error):
                    print("Error loading image: \(error)")
                    self.imageState = .failure(error)
                }
            }
        }
    }
    
}
