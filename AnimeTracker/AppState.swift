//
//  AppState.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 1/29/23.
//

import Foundation

// single source of truth for user's data, authentication tokens, screen navigation state (selected tabs, presented sheets)
class AppState: ObservableObject {
    let defaults = UserDefaults.standard // used to store basic types, we use it to store user setting's preferences
    
}
