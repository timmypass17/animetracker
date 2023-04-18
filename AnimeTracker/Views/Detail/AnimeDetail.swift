//
//  AnimeCellDetail.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 11/5/22.
//

import SwiftUI

// TODO: Refrator code to have optional animeNode
struct AnimeDetail: View {
    @EnvironmentObject var animeViewModel: AnimeViewModel
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    @StateObject var detailViewModel = DetailViewModel()
    
    // Can't move these into viewmodel for some reason
    @State var item: WeebItem?
    let id: Int
    let type: WeebItemType // do not need this because once we get item, we can refer if next items will be all anime or all manga. Not possible to jump between anime and manga
    
    var body: some View {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0) {
                    DetailTopSection(item: item)
    
                    GenreRow(animeNode: item)
                        .font(.caption)
                        .padding(.top)
    
                    DetailProgress(item: $item)
                        .padding(.top)
                    
                    DetailTabView(selectedTab: $detailViewModel.selectedTab)
                        .padding(.top)
                        .unredacted()
                    
                    switch detailViewModel.selectedTab {
                    case .background:
                        Synopsis(animeNode: item)
                            .padding(.top)
                        
                        if let relatedAnimes = (item as? Anime)?.related_anime {
                            RelatedRow(
                                relatedItems: relatedAnimes,
                                type: .anime
                            )
                            .padding(.top)
                        }

                        if let relatedMangas = (item as? Manga)?.related_manga {
                            RelatedRow(
                                relatedItems: relatedMangas,
                                type: .manga
                            )
                            .padding(.top)
                        }
                    case .statistic:
                        AnimeStats(item: item)
                            .padding(.top)
                    case .recommendation:
                        RecommendationRow(
                            recommendedItems: item?.recommendations ?? [],
                            type: type
                        )
                        .padding(.top)
                    }
                    
                    
                }
                .padding()
                .padding(.top, 115) // 45
                .background(alignment: .top) {
                    if let url = item?.main_picture?.large {
                        DetailBackground(url: url)
                    }
                }
                
                Spacer()
            }
            .redacted(reason: item == nil ? .placeholder : [])
            .foregroundColor(.white)
            .edgesIgnoringSafeArea(.top)
            .navigationTitle(item?.getTitle() ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $detailViewModel.isShowingSheet, onDismiss: { /** Save data **/ }, content: {
                NavigationView {
                    EpisodeSheet(item: $item, isShowingSheet: $detailViewModel.isShowingSheet, type: type)
                }
                .presentationDetents([.medium])
            })
            .toolbar {
                ToolbarItemGroup {
    //                if animeViewModel.animeData.contains(where: { $0.node.id == id }) {
    //                    Button(role: .destructive) {
    //                        showDeleteAlert = true
    //                    } label: {
    //                        Image(systemName: "trash")
    //
    //                    }
    //                }
                    
                    Button(action: { detailViewModel.isShowingSheet.toggle() }) {
                        Image(systemName: "plus") // plus.square
                            .imageScale(.large)
                        
                    }
                }
            }
            .background(Color.ui.background)
            .onAppear {
                Task {
                    //                isLoading = true
                    await fetchItem()
                    detailViewModel.isLoading = false
                }
            }
            .alert(
                "Delete Progress",
                isPresented: $detailViewModel.showDeleteAlert,
                presenting: item
            ) { animeNode in
                Button(role: .destructive) {
                    Task {
    //                    await animeViewModel.deleteAnime(animeNode: item)
                    }
                } label: {
                    Text("Delete")
                }
                
                Button(role: .cancel) {
                    
                } label: {
                    Text("Cancel")
                }
            } message: { item in
                Text("Are you sure you want to delete your progress for \"\(item.getTitle())\"?")
            }
//            .alert(isPresented: $appState.showAlert) {
//                switch appState.activeAlert {
//                case .iCloudNotLoggedIn:
//                    return Alert(title: Text("Unable to save record!"),
//                          message: Text("Please login to an iCloud account."),
//                          dismissButton: .default(Text("Got it!"))
//                    )
//                }
//            }
        .animation(.easeInOut, value: 1.0)
    }
    
    func fetchItem() async {
        // Cached
        if let existingItem = animeViewModel.userAnimeMangaList.first(where: { $0.id == id }) {
            print("Hit cached item")
            item = existingItem
            return
        }
        
        // Send network request
        switch type {
        case .anime:
            item = await animeViewModel.fetchAnime(id: id)
        default:
            item = await animeViewModel.fetchMangaByID(id: id)
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
            AnimeDetail(item: SampleData.sampleData[0], id: 0, type: .anime)
                .environmentObject(AnimeViewModel(animeRepository: AnimeRepository(), appState: AppState()))
                .environmentObject(DiscoverViewModel(animeRepository: AnimeRepository()))

        }

        NavigationView {
            AnimeDetail(item: nil, id: 0, type: .manga)
                .environmentObject(AnimeViewModel(animeRepository: AnimeRepository(), appState: AppState()))
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
