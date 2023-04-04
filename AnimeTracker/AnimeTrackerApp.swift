//
//  AnimeTrackerApp.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/23/22.
//

import SwiftUI


@main
struct AnimeTrackerApp: App {
    @StateObject var appState: AppState
    @StateObject var animeViewModel: AnimeViewModel
    @StateObject var discoverViewModel: DiscoverViewModel

    init() {
        // https://swiftui-lab.com/random-lessons/#data-10
        let appState = AppState()
        let animeRepository = AnimeRepository()
        _appState = StateObject(wrappedValue: appState)
        _animeViewModel = StateObject(wrappedValue: AnimeViewModel(animeRepository: animeRepository))
        _discoverViewModel = StateObject(wrappedValue: DiscoverViewModel(animeRepository: animeRepository))
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
            }
            .environmentObject(appState)
            .environmentObject(animeViewModel)
            .environmentObject(discoverViewModel)
        }
    }
}

extension Color {
    static let ui = Color.UI()
    
    struct UI {
        let background = Color("background")
        let card = Color("card")
        let tag = Color("tag")
        let tag_text = Color("tag_text")
        let textColor = Color("textColor")
    }
}
