//
//  EpisodeSheet.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/28/22.
//

import SwiftUI
import CloudKit

struct EpisodeSheet: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var animeViewModel: AnimeViewModel
    @Binding var isShowingSheet: Bool
    @Binding var animeNode: AnimeNode
    @Binding var current_episode: Float
    
    var maxSlider: Float {
        return animeNode.node.getNumEpisodesOrChapters() == 0 ? 2000.0 : Float(animeNode.node.getNumEpisodesOrChapters())
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Episode Progression")
                .font(.title)
                .bold()
            
            Text("Keep track of episodes watched!")
                .foregroundColor(.secondary)
            
            AnimeCell(animeNode: $animeNode)
            
            HStack {
                Button(action: { handleMinus() }) {
                    Image(systemName: "minus")
                }
                
                // TODO: Some animes don't have num count (ex. One Piece)
                Slider(
                    value: $current_episode,
                    in: 0...maxSlider,
                    step: 1
                ) {
                    Text("Episode")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("\(animeNode.node.getNumEpisodesOrChapters() == 0 ? "?" : String(animeNode.node.getNumEpisodesOrChapters()))")
                }
                Button(action: { handlePlus() }) {
                    Image(systemName: "plus")
                }
            }
            .padding(.top, 10)
            
            Text("Currently on episode: \(Int(current_episode)) / \(animeNode.node.getNumEpisodesOrChapters() == 0 ? "?": String(animeNode.node.getNumEpisodesOrChapters())) ")
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
            .alert(isPresented: $animeViewModel.showErrorAlert) {
                Alert(title: Text("Unable to save record!"),
                      message: Text("Please login to an iCloud account."),
                      dismissButton: .default(Text("Got it!"))
                )
            }
            .alert(isPresented: $animeViewModel.showSucessAlert) {
                Alert(title: Text("Saved record successfully!"),
                      dismissButton: .default(Text("Got it!"))
                )
            }
        }
        .padding()
        .padding(.top) // sheet needs extra top padding
        .onAppear {
            current_episode = Float(animeNode.episodes_seen)
            print(maxSlider)
        }
    }
    
    func handlePlus() {
        current_episode = min(current_episode + 1, Float(animeNode.node.num_episodes ?? Int.max))
    }
    
    func handleMinus() {
        current_episode = max(current_episode - 1, 0)
    }
    
    // TODO: Bug
    func handleSaveAction() {
        Task {
            // user may relog into icloud so we need to check again.
            await appState.getiCloudUser()
            if appState.isSignedInToiCloud {
                isShowingSheet = false
                animeNode.episodes_seen = Int(current_episode)
                await animeViewModel.addAnime(animeNode: animeNode)
            } else {
                animeViewModel.showErrorAlert = true
            }
        }
    }
}

struct EpisodeSheet_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EpisodeSheet(isShowingSheet: .constant(true), animeNode: .constant(AnimeCollection.sampleData[0]), current_episode: .constant(100.0))
                .environmentObject(AnimeViewModel(animeRepository: AnimeRepository()))
        }
    }
}

extension Binding where Value == Int {
    public func float() -> Binding<Float> {
        return Binding<Float>(get:{ Float(self.wrappedValue) },
            set: { self.wrappedValue = Int($0)})
    }
}
