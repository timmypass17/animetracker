//
//  AnimeTrackerApp.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 10/23/22.
//

import SwiftUI

enum DetailDestination: Hashable {
    case anime(Int)
    case manga(Int)
}

@main
struct AnimeTrackerApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject var appState: AppState
    @StateObject var animeViewModel: AnimeViewModel
    @StateObject var discoverViewModel: DiscoverViewModel
    @StateObject var profileViewModel: ProfileViewModel
    
    init() {
        // https://swiftui-lab.com/random-lessons/#data-10
        let appState = AppState()
        let animeRepository = AnimeRepository()
        _appState = StateObject(wrappedValue: appState)
        _animeViewModel = StateObject(wrappedValue: AnimeViewModel(animeRepository: animeRepository))
        _discoverViewModel = StateObject(wrappedValue: DiscoverViewModel(animeRepository: animeRepository))
        _profileViewModel = StateObject(wrappedValue: ProfileViewModel(animeRepository: animeRepository))
                
//        Task {
//            // Ask only once (to show again, delete and reinstall app)
//            try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
//        }
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack(path: $appState.homePath) {
                    HomeView()
                        .navigationDestination(for: DetailDestination.self) { destination in
                            switch destination {
                            case .anime(let id):
                                AnimeDetail(id: id, type: .anime)
                            case .manga(let id):
                                AnimeDetail(id: id, type: .manga)
                            }
                        }
                }
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
                
                NavigationStack(path: $appState.discoverPath) {
                    DiscoverView()
                        .navigationDestination(for: DetailDestination.self) { destination in
                            switch destination {
                            case .anime(let id):
                                AnimeDetail(id: id, type: .anime)
                            case .manga(let id):
                                AnimeDetail(id: id, type: .manga)
                            }
                        }
                }
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
                
                // TODO: Add settings, user defaults, remove all, import animes, display different list styles
                NavigationStack(path: $appState.profilePath) {
                    ProfileView()
                }
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
            }
            .environmentObject(appState)
            .environmentObject(animeViewModel)
            .environmentObject(discoverViewModel)
            .environmentObject(profileViewModel)
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
