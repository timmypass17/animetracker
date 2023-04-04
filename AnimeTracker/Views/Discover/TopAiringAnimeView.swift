//
//  TopAiringAnimeView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 3/29/23.
//

import SwiftUI

struct TopAiringAnimeView: View {
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    
    var body: some View {
        TopAiringAnimeRow()
    }
}

struct TopAiringAnimeRow: View {
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    
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
    
    
    var body: some View {
        if discoverViewModel.topAiringAnimes.data.count > 0 {
            VStack(alignment: .leading) {
                HStack {
                    Text("Top Airing Animes")
                        .font(.title3)
                    
                    Spacer()
                    
                    
                }
                .contentShape(Rectangle())
                .padding(.horizontal)
                
                TabView {
                    ForEach(discoverViewModel.topAiringAnimes.data, id: \.node.id) { animeNode in
                        NavigationLink {
                            AnimeDetail(id: animeNode.node.id, animeType: .anime)
                        } label: {
                            DetailTopSection(animeNode: animeNode)
                                .padding()
                                .background(alignment: .top) {
                                    if let url = animeNode.node.main_picture?.large {
                                        DetailBackground(url: url)
                                            .opacity(0.5)
                                            .overlay(leftGradient)
                                            .overlay(rightGradient)
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
            TopAiringAnimeView()
            TopAiringAnimeRow()
        }
        .environmentObject(DiscoverViewModel(animeRepository: AnimeRepository()))
    }
}
