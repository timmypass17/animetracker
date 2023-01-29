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
    @StateObject var animeViewModel = AnimeViewModel()
    @StateObject var discoverViewModel = DiscoverViewModel()

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
