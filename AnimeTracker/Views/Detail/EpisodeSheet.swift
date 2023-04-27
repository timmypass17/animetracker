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
    @State var progress: Float = 0.0
    @Binding var item: WeebItem?
    @Binding var isShowingSheet: Bool
    let type: WeebItemType?
    @State var isLoading = false
    
    var title: String {
        return "\(type == .anime ? "Episode" : "Chapter") Progression"
    }
    
    var subtitle: String {
        if type == .anime {
            return "Keep track of episodes watched!"
        } else {
            return "Keep track of chapters read!"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.title)
                    .bold()
            }
            
            Text(subtitle)
                .foregroundColor(.secondary)
            
            if let anime = item as? Anime {
                WeebCell(item: anime)
                    .padding(.top)
                    .padding(.bottom, 8)
                
                Divider()
                    .padding(.bottom, 8)
                
                // TODO: Turn this into 1 view
                if anime.getNumEpisodes() > 0 {
                    ProgressionSlider(
                        item: anime,
                        progress: $progress,
                        maxEpisodeOrChapter: anime.getNumEpisodes()
                    )
                } else {
                    ProgressionStepper(
                        item: anime,
                        progress: $progress,
                        maxEpisodeOrChapter: anime.getNumEpisodes()
                    )
                }
            } else if let manga = item as? Manga {
                WeebCell(item: manga)
                
                if manga.getNumChapters() > 0 {
                    ProgressionSlider(
                        item: manga,
                        progress: $progress,
                        maxEpisodeOrChapter: manga.getNumChapters()
                    )
                } else {
                    ProgressionStepper(
                        item: manga,
                        progress: $progress,
                        maxEpisodeOrChapter: manga.getNumChapters()
                    )
                }
            }
            
            Spacer()
            
            Button(action: {
                guard let item = item else { return }
                isLoading = true
                
                Task {
                    // struct is immutable, have to reassign entire object
                    let updatedItem = await animeViewModel.saveProgress(item: item, seen: Int(progress))
                    print("got item")
                    if let updatedItem = updatedItem {
                        // Updated item sucessfully
                        self.item = updatedItem
                        isShowingSheet = false
                    } else {
                        appState.activeAlert = .iCloudNotLoggedIn
                        appState.showAlert = true
                    }
                    isLoading = false
                }
            }) {
                // save to icloud
                Group {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(Color.accentColor)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
        }
        .padding()
        .padding(.top)
        .onAppear {
            progress = Float(item?.progress?.seen ?? 0)
        }
        .alert(isPresented: $appState.showAlert) {
            switch appState.activeAlert {
            case .iCloudNotLoggedIn:
                return Alert(
                    title: Text("Unable to save progress!"),
                      message: Text("Please verify that you are logged into your iCloud account by going to Settings > iCloud on your device.")
                )
            }
        }
//        .overlay {
//            if isLoading {
//                ProgressView()
//            }
//        }
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
                item: .constant(SampleData.sampleData[0]),
                isShowingSheet: .constant(true),
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
