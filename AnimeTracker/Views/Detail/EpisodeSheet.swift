//
//  EpisodeSheet.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/28/22.
//

import SwiftUI
import CloudKit

enum ActiveAlert {
    case failure
}

struct EpisodeSheet: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var animeViewModel: AnimeViewModel
    @Binding var item: WeebItem?
    @State var progress: Float = 0.0
    
    @Binding var isShowingSheet: Bool
    @State var activeAlert: ActiveAlert = .failure
    @State var showAlert = false
    let type: WeebItemType?
    
    var body: some View {
            VStack(alignment: .leading) {
                Text("Episode Progression")
                    .font(.title)
                    .bold()

                Text("Keep track of episodes watched!")
                    .foregroundColor(.secondary)
                
                if let anime = item as? Anime {
                    AnimeCell(anime: anime)

                    HStack {
                        Button(action: { handleMinus() }) {
                            Image(systemName: "minus")
                        }
                        
                        // TODO: Some animes don't have num count (ex. One Piece)
                        Slider(
                            value: $progress,
                            in: 0.0...Float(anime.getNumEpisodes()),
                            step: 1.0
                        ) {
                            Text("Episode")
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("")
                        }
                        Button(action: { handlePlus() }) {
                            Image(systemName: "plus")
                        }
                    }
                    .padding(.top, 10)
                    
                    Text("Currently on episode: \(Int(progress)) / \(anime.getNumEpisodes())")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.caption)
                }

                Spacer()

                Button(action: {
                    Task {
                        if let item = item {
                            await animeViewModel.saveProgress(item: item, seen: Int(progress))
                        }
                    }
                }) {
                    // save to icloud
                    Text("Save")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .alert(isPresented: $showAlert) {
                    switch activeAlert {
                    case .failure:
                        return Alert(title: Text("Unable to save record!"),
                              message: Text("Please login to an iCloud account."),
                              dismissButton: .default(Text("Got it!"))
                        )
                    }
                }
            }
            .padding()
            .padding(.top)
            .onAppear {
                progress = Float(item?.progress?.seen ?? 0)
        }
    }
    
    func handlePlus() {
        if let anime = item as? Anime {
            progress = min((progress) + 1, Float(anime.getNumEpisodes()))
        } else if let manga = item as? Manga {
            progress = min((progress) + 1, Float(manga.getNumChapters()))
        }
    }
    
    func handleMinus() {
        progress = max((progress) - 1, 0)
    }
}

struct EpisodeSheet_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EpisodeSheet(
                isShowingSheet: .constant(true),
                item: .constant(SampleData.sampleData[0]),
                type: .anime
            )
                .environmentObject(AppState())
                .environmentObject(AnimeViewModel(animeRepository: AnimeRepository()))
        }
    }
}

struct IntFromDoubleBinding {
    var intValue: Binding<Int>
    var doubleValue: Binding<Double>
    
    init(_ intValue: Binding<Int>) {
        self.intValue = intValue
        self.doubleValue = Binding<Double>(get: { Double(intValue.wrappedValue) }, set: { intValue.wrappedValue = Int($0)} )
    }
}
