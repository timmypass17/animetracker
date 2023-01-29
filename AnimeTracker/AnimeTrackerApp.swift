//
//  AnimeTrackerApp.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/23/22.
//

import SwiftUI


@main
struct AnimeTrackerApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var animeViewModel: AnimeViewModel
    @StateObject var discoverViewModel: DiscoverViewModel
    
    // inject repo into viewmodel to share repo with multible viewmodels
    init() {
        // https://swiftui-lab.com/random-lessons/#data-10
        let animeRepository = AnimeRepository()
        self._animeViewModel = StateObject(wrappedValue: AnimeViewModel(animeRepository: animeRepository))
        self._discoverViewModel = StateObject(wrappedValue: DiscoverViewModel(animeRepository: animeRepository))
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
                
                Text("Friend View")
                    .tabItem {
                        Label("Friends", systemImage: "person.2")
                    }
            }
            .environmentObject(authViewModel)
            .environmentObject(animeViewModel)
            .environmentObject(discoverViewModel)
        }
    }
}
