//
//  AnimeTrackerApp.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/23/22.
//

import SwiftUI

enum Tab {
    case list
    case search
    case chart
}

@main
struct AnimeTrackerApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var homeViewModel = HomeViewModel()
    @StateObject var searchViewModel = SearchViewModel()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    HomeView()
                }
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
                .environmentObject(authViewModel)
                .environmentObject(homeViewModel)
                
                NavigationStack {
                    SearchView()
                }
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .environmentObject(homeViewModel)
                .environmentObject(searchViewModel)
                
                Text("Chart View")
                    .tabItem {
                        Label("Chart", systemImage: "chart.bar.fill")
                    }
            }
        }
    }
}
