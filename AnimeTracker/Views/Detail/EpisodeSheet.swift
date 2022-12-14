//
//  EpisodeSheet.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/28/22.
//

import SwiftUI
import CloudKit

struct EpisodeSheet: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State var isEditing = false
    @Binding var isShowingSheet: Bool
    @Binding var animeNode: AnimeNode
//    @Binding var isBookmarked: Bool
    @Binding var current_episode: Float
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Episode Progression")
                .font(.title)
                .bold()
            
            Text("Keep track of episodes watched!")
                .foregroundColor(.secondary)
            
            AnimeCell(animeNode: $animeNode)
            
            HStack {
                Button(action: { animeNode.episodes_seen = max(animeNode.episodes_seen - 1, 0) }) {
                    Image(systemName: "minus")
                }
                
                // TODO: Some animes don't have num count (ex. One Piece)
                Slider(
                    value: $current_episode,
                    in: 0...Float(animeNode.node.num_episodes),
                    step: 1
                ) {
                    Text("Episode")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("\(animeNode.node.num_episodes)")
                } onEditingChanged: { editing in
                    isEditing = editing
                }
                
                Button(action: { animeNode.episodes_seen = min(animeNode.episodes_seen + 1, animeNode.node.num_episodes) }) {
                    Image(systemName: "plus")
                }
            }
            .padding(.top, 10)
            
            Text("Currently on episode: \(Int(current_episode)) / \(animeNode.node.num_episodes)")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.caption)
            
            Spacer()
            
            Button(action : { handleSaveAction() }) {
                // save to icloud
                Text("Save")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .padding(.top) // sheet needs extra top padding
        .onAppear {
            current_episode = Float(animeNode.episodes_seen)
        }
    }
    
    func handleSaveAction() {
        Task {
            isShowingSheet = false
            animeNode.episodes_seen = Int(current_episode)
            await homeViewModel.addAnime(animeNode: animeNode)
        }
    }
}

struct EpisodeSheet_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EpisodeSheet(isShowingSheet: .constant(true), animeNode: .constant(AnimeCollection.sampleData[0]), current_episode: .constant(100.0))
        }
    }
}
