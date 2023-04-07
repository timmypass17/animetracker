//
//  PopularMangas.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 3/29/23.
//

import SwiftUI

struct PopularMangas: View {
    @EnvironmentObject var discoverViewModel: DiscoverViewModel
    var geometry: GeometryProxy

    var body: some View {
        PopularMangasRow(geometry: geometry)
    }
}

struct PopularMangasRow: View {
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
    
    
    var body: some View {
        if discoverViewModel.popularMangas.data.count > 0 {
            VStack(alignment: .leading) {
                NavigationLink {
                    DiscoverDetailView(
                        year: 0,
                        season: .fall,
                        animeType: .anime,
                        geometry: geometry,
                        loadMore: discoverViewModel.fetchPopularMangas
                    )
                    .navigationTitle("Popular Mangas")
                } label: {
                    HStack {
                        Text("Popular Mangas".uppercased())
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
                    ForEach(discoverViewModel.popularMangas.data, id: \.node.id) { animeNode in
                        NavigationLink {
                            AnimeDetail(id: animeNode.node.id, animeType: .manga)
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
struct PopularMangas_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GeometryReader { geometry in
                PopularMangas(geometry: geometry)
                PopularMangasRow(geometry: geometry)
            }
        }
        .environmentObject(DiscoverViewModel(animeRepository: AnimeRepository()))
    }
}

