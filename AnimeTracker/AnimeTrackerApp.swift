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
        _animeViewModel = StateObject(wrappedValue: AnimeViewModel(animeRepository: animeRepository, appState: appState))
        _discoverViewModel = StateObject(wrappedValue: DiscoverViewModel(animeRepository: animeRepository))
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack(path: $appState.path) {
                    HomeView()
                        .navigationDestination(for: Int.self) { id in
                            AnimeDetail(id: id, type: .anime)
                        }
                }
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
                
                NavigationStack(path: $appState.path) {
                    DiscoverView()
                }
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
                
                // TODO: Add settings, user defaults, remove all, import animes, display different list styles
                NavigationStack(path: $appState.path) {
                    Text("Settings View")
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            }
            .environmentObject(appState)
            .environmentObject(animeViewModel)
            .environmentObject(discoverViewModel)
        }
    }
}

enum ActiveAlert {
    case iCloudNotLoggedIn
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
