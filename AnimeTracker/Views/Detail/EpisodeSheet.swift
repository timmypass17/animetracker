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
    @Binding var currentEpisode: Float
    @Binding var isShowingSheet: Bool
    @Binding var animeNode: AnimeNode
    @Binding var isBookmarked: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Episode Progression")
                .font(.title)
                .bold()
            
            Text("Keep track of episodes watched!")
                .foregroundColor(.secondary)
            
            AnimeCell(animeNode: $animeNode)
            
            HStack {
                Button(action: { currentEpisode = max(currentEpisode - 1.0, 0.0) }) {
                    Image(systemName: "minus")
                }
                
                // TODO: Some animes don't have num count (ex. One Piece)
                Slider(
                    value: $currentEpisode,
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
                
                Button(action: { currentEpisode = min(currentEpisode + 1.0, Float(animeNode.node.num_episodes)) }) {
                    Image(systemName: "plus")
                }
            }
            .padding(.top, 10)
            
            Text("Currently on episode: \(Int(currentEpisode)) / \(animeNode.node.num_episodes)")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.caption)
            
            Spacer()
            
            Button(action : { handleSaveAction() } ) {
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
            self.currentEpisode = animeNode.record["episodes_seen"] as? Float ?? 0.0
        }
    }
    
    func handleSaveAction() {
        Task {
            isShowingSheet = false
            // swiftui doesnt let me update record field, i would have to create an entirely new record for it to trigger a ui update...
            let record = CKRecord(recordType: "Anime")
            record.setValuesForKeys([
                "id": animeNode.node.id,
                "episodes_seen": Int(currentEpisode),
            ])
            animeNode.record = record
            await homeViewModel.addAnime(anime: animeNode.node, episodes_seen: Int(currentEpisode), isBookedmarked: isBookmarked)
        }
    }
}

struct EpisodeSheet_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EpisodeSheet(currentEpisode: .constant(0.0), isShowingSheet: .constant(true), animeNode: .constant(AnimeCollection.sampleData[0]), isBookmarked: .constant(false))
        }
    }
}
