//
//  CloudKitApi.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/17/23.
//

import Foundation

protocol CloudKitService {
    
    func saveAnime(animeNode: AnimeNode) async

    func fetchAnimesFromCloudKit() async -> [AnimeNode]
    
    func deleteAnime(animeNode: AnimeNode) async
}
