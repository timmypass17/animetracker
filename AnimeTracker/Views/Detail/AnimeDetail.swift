//
//  AnimeCellDetail.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 11/5/22.
//

import SwiftUI

// Note: Could have multible anime detail screens so we store state seperately
struct AnimeDetail: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    @State var animationAmount = 1.0
    @State var animeNode: AnimeNode = AnimeNode(node: Anime())
    @State var isShowingSheet = false
    @State var currentEpisode: Float = 0.0
    let animeID: Int
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
//                DetailBackground(animeNode: $animeNode)
                
                VStack(alignment: .leading, spacing: 0) {
                    DetailTopSection(animeNode: animeNode)
                    
                    GenreRow(animeNode: animeNode)
                        .padding(.top)
                    
                    DetailProgress(animeNode: $animeNode, current_episode: $currentEpisode)
                        .padding(.top)
                    
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
                    
                    if let recommended_animes = animeNode.node.recommendations {
                        if recommended_animes.count > 0 {
                            RelatedRow(
                                title: "Recommendations",
                                relatedAnimes: animeNode.node.recommendations ?? []
                            )
                            .padding(.top)
                        }
                    }
                                        
                    Button(action: {
                        Task {
                            dismiss()
                            await homeViewModel.deleteAnime(animeNode: animeNode)
                        }
                    }) {
                        Text("Delete Anime")
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)
                }
                .padding()
                .padding(.top, 115)
//                .offset(y: -230) // to overlap background image
                .background(alignment: .top) {
                    DetailBackground(animeNode: $animeNode)
                }
                
                Spacer()
            }
        }
        
        .foregroundColor(.white)
        .edgesIgnoringSafeArea(.top)
//        .background(.black)
//        .ignoresSafeArea()
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
                Button(action: {
                    Task {
                        animeNode.bookmarked.toggle()
                        await homeViewModel.addAnime(animeNode: animeNode)
                    }
                }) {
                    Image(systemName: "bookmark")
                        .foregroundColor(.yellow)
                        .symbolVariant(animeNode.bookmarked ? .fill : .none)
                }
                
                Button(action: { isShowingSheet.toggle() }) {
                    Image(systemName: "plus.square")
                        .imageScale(.large)
                }
            }
        }
        .onAppear {
            print("AnimeDetail onAppear()")
            Task {
                // get anime data from local cache
                if let existingNode = homeViewModel.animeData.first(where: { $0.node.id == animeID }) {
                    print("exists")
                    animeNode = existingNode
                } else {
                    // send api network request
                    print("network request")
                    animeNode = try await homeViewModel.fetchAnimeByID(id: animeID)
                }
            }
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
                .environmentObject(HomeViewModel())
        }
    }
}
