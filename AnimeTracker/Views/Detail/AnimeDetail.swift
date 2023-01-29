//
//  AnimeCellDetail.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 11/5/22.
//

import SwiftUI

// Note: Could have multible anime detail screens so we store state seperately
struct AnimeDetail: View {
    @EnvironmentObject var animeViewModel: AnimeViewModel
    @Environment(\.dismiss) private var dismiss
    @State var animationAmount = 1.0
    @State var animeNode: AnimeNode = AnimeNode(node: Anime())
    @State var isShowingSheet = false
    @State var currentEpisode: Float = 0.0
    @State var selectedTab: DetailTab = .background
    let animeID: Int
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                DetailTopSection(animeNode: animeNode)
                
                GenreRow(animeNode: animeNode)
                    .padding(.top)
                
                DetailProgress(animeNode: $animeNode, current_episode: $currentEpisode)
                    .padding(.top)
                
                DetailTabView(selectedTab: $selectedTab)
                    .padding(.top)
                
                switch selectedTab {
                case .background:
                    Synopsis(animeNode: animeNode)
                        .padding(.top)
                    
                    if let related_animes = animeNode.node.related_anime {
                        if related_animes.count > 0 {
                            RelatedRow(
                                title: "Related Anime",
                                relatedAnimes: related_animes
                            )
                            .padding(.top)
                        }
                    }
                case .statistic:
                    AnimeStats(animeNode: animeNode)
                        .padding(.top)
                case .recommendation:
                    if let recommended_animes = animeNode.node.recommendations {
                        if recommended_animes.count > 0 {
                            RelatedRow(
                                title: "Recommendations",
                                relatedAnimes: animeNode.node.recommendations ?? []
                            )
                            .padding(.top)
                        }
                    } else {
                        Text("No recommended anime.")
                    }
                }
                

                Button(action: {
                    Task {
                        dismiss()
                        await animeViewModel.deleteAnime(animeNode: animeNode)
                    }
                }) {
                    Text("Delete Anime")
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)

            }
            .padding()
            .padding(.top, 115) // 45
            .background(alignment: .top) {
                DetailBackground(animeNode: $animeNode)
            }
            
            Spacer()
        }
        
        .foregroundColor(.white)
        .edgesIgnoringSafeArea(.top)
        .navigationTitle(animeNode.node.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingSheet, onDismiss: { /** Save data **/ }, content: {
            NavigationView {
                EpisodeSheet(isShowingSheet: $isShowingSheet, animeNode: $animeNode, current_episode: $currentEpisode)
            }
            .presentationDetents([.medium])
        })
        .toolbar {
            ToolbarItemGroup {
//                Button(action: {
//                    Task {
//                        animeNode.bookmarked.toggle()
//                        await homeViewModel.addAnime(animeNode: animeNode)
//                    }
//                }) {
//                    Image(systemName: "bookmark")
//                        .foregroundColor(.yellow)
//                        .symbolVariant(animeNode.bookmarked ? .fill : .none)
//                }
                
                Button(action: { isShowingSheet.toggle() }) {
                    Image(systemName: "plus") // plus.square
                        .imageScale(.large)
                }
            }
        }
        .background(Color.ui.background)
        .onAppear {
            print("AnimeDetail onAppear()")
            Task {
                try await handleFetchingData()
            }
        }
    }
    
    func handleFetchingData() async throws {
        // get anime data from local cache
        if let existingNode = animeViewModel.animeData.first(where: { $0.node.id == animeID }) {
            animeNode = existingNode
        } else {
            // send api network request
            animeNode = try await animeViewModel.fetchAnimeByID(id: animeID)
        }
    }
}

enum DetailOption: String, CaseIterable, Identifiable {
    case synopsis, statistic, recommendation
    var id: Self { self } // forEach
}

struct AnimeDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnimeDetail(animeNode: AnimeCollection.sampleData[0], animeID: 0)
                .environmentObject(AnimeViewModel())
        }
    }
}
