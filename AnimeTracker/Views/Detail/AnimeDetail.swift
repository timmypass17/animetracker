//
//  AnimeCellDetail.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 11/5/22.
//

import SwiftUI

// Note: Could have multible anime detail screens so we store state seperately
struct AnimeDetail: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var animeViewModel: AnimeViewModel
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    @State var animationAmount = 1.0
    @State var animeNode: AnimeNode = AnimeNode(node: Anime(id: 0))
    @State var isShowingSheet = false
    @State var currentEpisode: Float = 0.0
    @State var selectedTab: DetailTab = .background
    let id: Int
    let animeType: AnimeType
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                DetailTopSection(animeNode: animeNode)
                
                GenreRow(animeNode: animeNode)
                    .font(.caption)
                    .padding(.top)
                
                DetailProgress(animeNode: $animeNode)
                
//                DetailProgress(animeNode: $animeNode, current_episode: $currentEpisode)
//                    .padding(.top)
                
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
                                relatedAnimes: related_animes,
                                animeType: .anime
                            )
                            .padding(.top)
                        }
                    }
                    
                    if let related_mangas = animeNode.node.related_manga {
                        if related_mangas.count > 0 {
                            RelatedRow(
                                title: "Related Mangas",
                                relatedAnimes: related_mangas,
                                animeType: .manga
                            )
                            .padding(.top)
                        }
                    }
                    
                    if animeViewModel.animeData.contains(where: { $0.node.id == id }) {
                        Button(action: {
                            Task {
                                dismiss()
                                await animeViewModel.deleteAnime(animeNode: animeNode)
                                animeViewModel.applySort()
                            }
                        }) {
                            Text("Delete Anime")
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                    }
                case .statistic:
                    AnimeStats(animeNode: animeNode)
                        .padding(.top)
                case .recommendation:
                    if let recommended_animes = animeNode.node.recommendations {
                        if recommended_animes.count > 0 {
                            RelatedRow(
                                title: "Recommendations",
                                relatedAnimes: animeNode.node.recommendations ?? [],
                                animeType: animeType
                            )
                            .padding(.top)
                        }
                    } else {
                        Text("No recommended anime.")
                    }
                }
                

            }
            .padding()
            .padding(.top, 115) // 45
            .background(alignment: .top) {
                DetailBackground(poster: animeNode.node.main_picture)
            }
            
            Spacer()
        }
        
        .foregroundColor(.white)
        .edgesIgnoringSafeArea(.top)
        .navigationTitle(animeNode.node.getTitle())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingSheet, onDismiss: { /** Save data **/ }, content: {
            NavigationView {
//                EpisodeSheet(isShowingSheet: $isShowingSheet, animeNode: $animeNode, current_episode: $currentEpisode)
                EpisodeSheet(isShowingSheet: $isShowingSheet, animeNode: $animeNode)
            }
            .presentationDetents([.medium])
        })
        .toolbar {
            ToolbarItemGroup {
                Button(action: { isShowingSheet.toggle() }) {
                    Image(systemName: "plus") // plus.square
                        .imageScale(.large)
                }
            }
        }
        .background(Color.ui.background)
        .onAppear {
            Task {
                try await loadAnimeData()
                
            }
        }
    }
    
    func loadAnimeData() async throws {
        // Cached
        if let existingNode = animeViewModel.animeData.first(where: { $0.node.id == id }) {
            animeNode = existingNode
            print("Existing \(animeNode.record.recordID.recordName)")
        } else {
            // Send network request
            switch animeType {
            case .anime:
                animeNode = try await animeViewModel.fetchAnime(id: id)
            default:
                animeNode = try await discoverViewModel.fetchMangaByID(id: id, animeType: animeType)
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
            AnimeDetail(animeNode: AnimeCollection.sampleData[1], id: 0, animeType: .anime)
                .environmentObject(AnimeViewModel(animeRepository: AnimeRepository()))
                .environmentObject(DiscoverViewModel(animeRepository: AnimeRepository()))
        }
    }
}
