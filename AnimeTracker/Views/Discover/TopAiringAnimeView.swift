//
//  TopAiringAnimeView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 3/29/23.
//

import SwiftUI

struct TopAiringAnimeView: View {
    var geometry: GeometryProxy
    
    var body: some View {
        TopAiringAnimeRow(geometry: geometry)
    }
}

struct TopAiringAnimeRow: View {
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    var geometry: GeometryProxy
    
    let leftGradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color.ui.background, location: 0),
            .init(color: .clear, location: 0.20)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    let rightGradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color.ui.background, location: 0),
            .init(color: .clear, location: 0.20)
        ]),
        startPoint: .trailing,
        endPoint: .leading
    )
    
    let gradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color.ui.background, location: 0),
            .init(color: .clear, location: 1.0) // 1.5 height of gradient
        ]),
        startPoint: .bottom,
        endPoint: .top
    )
    
    var body: some View {
        if discoverViewModel.topAiringAnimes.count > 0 {
            VStack(alignment: .leading) {
                NavigationLink {
                    DiscoverDetailView(
                        year: 0,
                        season: .fall,
                        animeType: .anime,
                        geometry: geometry,
                        loadMore: discoverViewModel.fetchTopAiringAnimes
                    )
                    .navigationTitle("Top Airing Animes")
                    .navigationBarTitleDisplayMode(.inline)
                } label: {
                    HStack {
                        Text("Top Airing Animes".uppercased())
                            .foregroundColor(Color.ui.textColor.opacity(0.6))
                        
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(Color.ui.textColor.opacity(0.6))
                    }
                    .contentShape(Rectangle())
                    .padding(.horizontal)
                }
                .buttonStyle(.plain)
                
                TabView {
                    ForEach(discoverViewModel.topAiringAnimes, id: \.id) { anime in
                        NavigationLink {
                            AnimeDetail(id: anime.id, type: .anime)
                        } label: {
                            DetailTopSection(item: anime)
                                .padding()
                                .background(alignment: .top) {
                                    if let url = anime.main_picture?.large {
                                        DetailBackground(url: url)
                                            .overlay(gradient)
//                                            .overlay(leftGradient)
//                                            .overlay(rightGradient)
                                    }
                                }
                                .padding(.vertical)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                .frame(height: 220)
                
                Divider()
            }
            .padding(.top)
        }
    }
}
struct TopAiringAnimeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GeometryReader { geometry in
                TopAiringAnimeView(geometry: geometry)
                TopAiringAnimeRow(geometry: geometry)
                
            }
        }
        .environmentObject(DiscoverViewModel(animeRepository: AnimeRepository()))
    }
}
