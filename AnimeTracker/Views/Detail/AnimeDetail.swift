//
//  AnimeCellDetail.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 11/5/22.
//

import SwiftUI

struct AnimeDetail: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var animeViewModel: AnimeViewModel
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    @State var animationAmount = 1.0
    @State var animeNode: AnimeNode = AnimeNode(node: Anime(id: 0))
    @State var isShowingSheet = false
    @State var currentEpisode: Float = 0.0
    @State var selectedTab: DetailTab = .background
    @State var isLoading = false
    @State var showDeleteAlert = false
    
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
                if let url = animeNode.node.main_picture?.large {
                    DetailBackground(url: url)
                }
            }
            
            Spacer()
        }
        .redacted(when: isLoading, redactionType: .customPlaceholder)
        .foregroundColor(.white)
        .edgesIgnoringSafeArea(.top)
        .navigationTitle(animeNode.node.getTitle())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingSheet, onDismiss: { /** Save data **/ }, content: {
            NavigationView {
                EpisodeSheet(isShowingSheet: $isShowingSheet, animeNode: $animeNode)
            }
            .presentationDetents([.medium])
        })
        .toolbar {
            ToolbarItemGroup {
                if animeViewModel.animeData.contains(where: { $0.node.id == id }) {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")

                    }
                }
                
                Button(action: { isShowingSheet.toggle() }) {
                    Image(systemName: "plus") // plus.square
                        .imageScale(.large)
                }
            }
        }
        .background(Color.ui.background)
        .onAppear {
            Task {
                isLoading = true
                try await loadAnimeData()
                isLoading = false
            }
        }
        .alert(
            "Delete Progress",
            isPresented: $showDeleteAlert,
            presenting: animeNode
        ) { animeNode in
            Button(role: .destructive) {
                Task {
                    await animeViewModel.deleteAnime(animeNode: animeNode)
                }
            } label: {
                Text("Delete")
            }
            
            Button(role: .cancel) {
                
            } label: {
                Text("Cancel")
            }
            
        } message: { anime in
            Text("Are you sure you want to delete your progress for \"\(anime.node.getTitle())\"?")
        }
//        .animation(.easeInOut, value: 1.0)
    }
    
    func loadAnimeData() async throws {
        // Cached
        print("loading")
        if let existingNode = animeViewModel.animeData.first(where: { $0.node.id == id }) {
            animeNode = existingNode
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

public enum RedactionType {
    case customPlaceholder
    case scaled
    case blurred
}

struct Redactable: ViewModifier {
    let type: RedactionType?

    @ViewBuilder
    func body(content: Content) -> some View {
        switch type {
        case .customPlaceholder:
            content
                .modifier(Placeholder())
        case .scaled:
            content
                .modifier(Scaled())
        case .blurred:
            content
                .modifier(Blurred())
        case nil:
            content
        }
    }
}

struct Placeholder: ViewModifier {

    @State private var condition: Bool = false
    func body(content: Content) -> some View {
        content
            .accessibility(label: Text("Placeholder"))
            .redacted(reason: .placeholder)
//            .opacity(condition ? 0.0 : 1.0)
//            .animation(Animation
//                        .easeInOut(duration: 1)
//                        .repeatForever(autoreverses: true))
            .onAppear { condition = true }
    }
}

struct Scaled: ViewModifier {

    @State private var condition: Bool = false
    func body(content: Content) -> some View {
        content
            .accessibility(label: Text("Scaled"))
            .redacted(reason: .placeholder)
            .scaleEffect(condition ? 0.9 : 1.0)
            .animation(Animation
                        .easeInOut(duration: 1)
                        .repeatForever(autoreverses: true))
            .onAppear { condition = true }
    }
}

struct Blurred: ViewModifier {

    @State private var condition: Bool = false
    func body(content: Content) -> some View {
        content
            .accessibility(label: Text("Blurred"))
            .redacted(reason: .placeholder)
            .blur(radius: condition ? 0.0 : 4.0)
            .animation(Animation
                        .easeInOut(duration: 1)
                        .repeatForever(autoreverses: true))
            .onAppear { condition = true }
    }
}

extension View {
    @ViewBuilder
    func redacted(when condition: Bool, redactionType: RedactionType) -> some View {
        if !condition {
            unredacted()
        } else {
            redacted(reason: redactionType)
        }
    }

    func redacted(reason: RedactionType?) -> some View {
        self.modifier(Redactable(type: reason))
    }
}
