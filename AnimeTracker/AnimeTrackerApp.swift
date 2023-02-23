//
//  AnimeTrackerApp.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/23/22.
//

import SwiftUI


@main
struct AnimeTrackerApp: App {
//    @StateObject var authViewModel = AuthViewModel()
    @StateObject var appState: AppState
    @StateObject var animeViewModel: AnimeViewModel
    @StateObject var discoverViewModel: DiscoverViewModel
    @StateObject var friendViewModel: FriendViewModel

    
    // inject repo into viewmodel to share repo with multible viewmodels
    init() {
        // https://swiftui-lab.com/random-lessons/#data-10
        _appState = StateObject(wrappedValue: AppState())
        let animeRepository = AnimeRepository()
        _animeViewModel = StateObject(wrappedValue: AnimeViewModel(animeRepository: animeRepository))
        _discoverViewModel = StateObject(wrappedValue: DiscoverViewModel(animeRepository: animeRepository))
        _friendViewModel = StateObject(wrappedValue: FriendViewModel())
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    HomeView()
                }
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
                
                NavigationStack {
                    DiscoverView()
                }
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
                
                NavigationStack {
                    FriendView()
                }
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }
                
            }
//            .environmentObject(authViewModel)
            .environmentObject(appState)
            .environmentObject(animeViewModel)
            .environmentObject(discoverViewModel)
            .environmentObject(friendViewModel)
        }
    }
}
