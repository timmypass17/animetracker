//
//  AnimeCellDetail.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 11/5/22.
//

import SwiftUI

enum DetailOption: String, CaseIterable, Identifiable {
    case synopsis, statistic, recommendation
    var id: Self { self } // forEach
}

struct AnimeDetail: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State var selectedViewType: ViewMode = .watching
    @State var animationAmount = 1.0
    @State var animeNode: AnimeNode = AnimeNode(node: Anime())
    @State var isBookmarked = false
    @State var isAdded = false
    @State var isShowingSheet = false
    @State var currentEpisode: Float = 0.0

    let animeID: Int
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                DetailBackground(animeNode: $animeNode)
                
                VStack(alignment: .leading, spacing: 0) {
                    DetailTopSection(
                        animeNode: animeNode,
                        selectedViewType: $selectedViewType
                    )
                    
                    GenreRow(animeNode: animeNode)
                        .padding(.top)
                    
                    DetailProgress(animeNode: $animeNode)
                        .padding(.top)
                    
                    Synopsis(animeNode: animeNode)
                        .padding(.top)
                    
                    // can either have related mangas or related animes
//                    if animeNode.node.media_type == "manga" {
//                        RelatedRow(
//                            title: "Related Manga",
//                            relatedAnimes: animeNode.node.related_manga
//                        )
//                        .padding(.top)
//                    } else {
//                        RelatedRow(
//                            title: "Related Anime",
//                            relatedAnimes: animeNode.node.related_anime
//                        )
//                        .padding(.top)
//                    }
                    
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
                            await homeViewModel.deleteAnime(recordToDelete: animeNode.record)
                        }
                    }) {
                        Text("Delete Anime")
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)
                }
                .padding()
                .offset(y: -230) // to overlap background image
                
                Spacer()
            }
        }
        .foregroundColor(.white)
        .background(.black)
        .ignoresSafeArea()
        .navigationTitle(animeNode.node.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingSheet, onDismiss: { /** Save data **/ }, content: {
            NavigationView {
                EpisodeSheet(currentEpisode: $currentEpisode, isShowingSheet: $isShowingSheet, animeNode: $animeNode, isBookmarked: $isBookmarked)
            }
            .presentationDetents([.medium])
        })
        .toolbar {
            ToolbarItemGroup {
                Button(action: {
                    isBookmarked.toggle()
                    Task {
                        await homeViewModel.addAnime(anime: animeNode.node, episodes_seen: Int(currentEpisode), isBookedmarked: isBookmarked)
                    }
                }) {
                    Image(systemName: "bookmark")
                        .foregroundColor(.yellow)
                        .symbolVariant(isBookmarked ? .fill : .none)
                }
                
                Button(action: { isShowingSheet.toggle() }) {
                    Image(systemName: "plus.square")
                        .imageScale(.large)
                }
            }
        }
        .onAppear {
            print("onAppear()")
            Task {
                // get anime data
                animeNode = try await homeViewModel.fetchAnimeByID(id: animeID)
                // Loop through cached user's list and get the episodes_seen value.
                // (Also if its bookedmarked)
                for item in homeViewModel.animeData {
                    if item.node.id == self.animeID {
                        animeNode.record = item.record
                        isBookmarked = animeNode.record["bookmarked"] as? Bool ?? false
                        break
                    }
                }
                
                
            }
        }
    }
}

struct AnimeDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnimeDetail(animeNode: AnimeCollection.sampleData[0], animeID: 0)
                .environmentObject(HomeViewModel())
        }
    }
}
