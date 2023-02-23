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
    @State var progress: Float = 0.0
    
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
                    value: $progress,
//                    value: Binding<Float>(
//                        get: { Float(animeNode.seen) },
//                        set: { animeNode.seen = Int($0) }
//                    ),
                    in: 0.0...maxSlider,
                    step: 1.0
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
            
            Text("Currently on episode: \(Int(progress)) / \(animeNode.node.getNumEpisodesOrChapters() == 0 ? "?": String(animeNode.node.getNumEpisodesOrChapters())) ")
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
        }
        .padding()
        .padding(.top) // sheet needs extra top padding
        .onAppear {
            progress = Float(animeNode.record.seen)
        }
    }
    
    func handlePlus() {
        progress = min((progress) + 1, Float(animeNode.node.num_episodes ?? Int.max))
    }
    
    func handleMinus() {
        progress = max((progress) - 1, 0)
    }
    
    // capture user input 
    func handleSaveAction() {
        Task {
            await appState.getiCloudUser()
            if appState.isSignedInToiCloud {
                isShowingSheet = false
                animeNode.record.animeID = animeNode.node.id
                animeNode.record.seen = Int(progress)
                animeNode.record.animeType = animeNode.node.animeType
                await animeViewModel.saveAnime(animeNode: animeNode)
            } else {
                animeViewModel.showErrorAlert = true
            }
        }
    }
}

//struct EpisodeSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            EpisodeSheet(isShowingSheet: .constant(true), animeNode: .constant(AnimeCollection.sampleData[0]), current_episode: .constant(100.0))
//                .environmentObject(AnimeViewModel(animeRepository: AnimeRepository()))
//        }
//    }
//}

//extension Binding where Value == Int {
//    public func float() -> Binding<Float> {
//        return Binding<Float>(get:{ Float(self.wrappedValue) },
//            set: { self.wrappedValue = Int($0)})
//    }
//}

struct IntFromDoubleBinding {
    var intValue: Binding<Int>
    var doubleValue: Binding<Double>
    
    init(_ intValue: Binding<Int>) {
        self.intValue = intValue
        self.doubleValue = Binding<Double>(get: { Double(intValue.wrappedValue) }, set: { intValue.wrappedValue = Int($0)} )
    }
}
