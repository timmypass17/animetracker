//
//  DetailViewModel.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/16/23.
//

import Foundation
import SwiftUI

@MainActor
class DetailViewModel: ObservableObject {
    @Published var isShowingSheet = false
    @Published var selectedTab: DetailTab = .background
    @Published var animationAmount = 1.0
    @Published var isLoading = false
    @Published var showDeleteAlert = false

}
