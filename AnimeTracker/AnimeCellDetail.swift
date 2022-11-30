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

struct AnimeCellDetail: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Binding var animeNode: AnimeNode
    @State var selectedViewType: ViewMode = .watching
    @State var seen = ""
    @State var animationAmount = 1.0
    @State var selectedOption: DetailOption = .synopsis
    
    var body: some View {
        ScrollView(.vertical) {

            VStack(spacing: 0) {
                AnimeBackground(animeNode: animeNode)
                
                VStack(spacing: 0) {
                    DetailTopSection(
                        animeNode: animeNode,
                        selectedViewType: $selectedViewType
                    )
                    
                    GenreRow(animeNode: animeNode)
                    
                    
                    Picker("View Mode", selection: $selectedOption) {
                        ForEach(DetailOption.allCases) { mode in
                            Text(mode.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .border(.purple)
                    
                    VStack {
                        switch selectedOption {
                        case .synopsis:
                            AnimeSynopsis(animeNode: animeNode)
                        case .statistic:
                            Text("Statistic view")
                        case.recommendation:
                            Text("Recommendation")
                        }
                    }
                    .border(.red)
                    
                    // remove later
                    Button(action: {
                        Task {
                            await homeViewModel.addAnime(anime: animeNode.node)
                        }
                    }) {
                        Text("add")
                            .foregroundColor(.white)
                    }
                    
                }
                .offset(y: -230) // to overlap background image
                
                Spacer()
            }
        }
        .foregroundColor(.white)
        .background(.black)
        .ignoresSafeArea()
    }
}

struct AnimeCellDetail_Previews: PreviewProvider {
    static var previews: some View {
        AnimeCellDetail(animeNode: .constant(AnimeCollection.sampleData[0]))
            .environmentObject(HomeViewModel())
    }
}

struct AnimeSynopsis: View {
    let animeNode: AnimeNode
    @State var showMore = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(animeNode.node.synopsis)
                .fixedSize(horizontal: false, vertical: true) // fixes text from being truncated "..." somehow
                .lineLimit(showMore ? nil : 4)
                .onTapGesture {
                    withAnimation {
                        showMore.toggle()
                        print(animeNode.node.synopsis)
                    }
                }
        }
        .padding()
    }
}

struct AnimeBackground: View {
    let animeNode: AnimeNode
    let gradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: .black, location: 0),
            .init(color: .clear, location: 1.5) // height of gradient
        ]),
        startPoint: .bottom,
        endPoint: .top
    )
    
    var body: some View {
        AsyncImage(url: URL(string: animeNode.node.main_picture.medium)) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(width: .infinity, height: 350)
                .clipShape(Rectangle())
                .overlay {
                    gradient
                }
        } placeholder: {
            ProgressView()
                .frame(width: 75, height: 125)
        }
    }
}

struct DetailTopSection: View {
    let animeNode: AnimeNode
    @Binding var selectedViewType: ViewMode
    
    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: URL(string: animeNode.node.main_picture.medium)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.secondary)
                    }
                    .shadow(radius: 2)
            } placeholder: {
                ProgressView()
                    .frame(width: 75, height: 125)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: "\(animeNode.node.start_season.season.capitalized) \(animeNode.node.start_season.year)")
                    .foregroundColor(.white.opacity(0.6))
                
                VStack(alignment: .leading, spacing: 0){
                    Text(animeNode.node.title)
                        .font(.title)
                    
                    Text(animeNode.node.alternative_titles.ja)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                HStack(spacing: 0) {
                    Text("\(animeNode.node.num_episodes) Episodes | ")
                    Text("\(animeNode.node.average_episode_duration / 60) min")
                }
                .font(.caption)
                
                Text(animeNode.node.status)
                    .font(.caption)
                
                HStack {
                    VStack(spacing: 2) {
                        Text("Score".uppercased())
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 1)
                            .background(RoundedRectangle(cornerRadius: 4).fill(.blue))
                        
                        Text(String(format: "%.2f", animeNode.node.mean))
                            .font(.system(size: 16))
                    }
                    
                    VStack(spacing: 2) {
                        Text("Rank".uppercased())
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 1)
                            .background(RoundedRectangle(cornerRadius: 4).fill(.blue))
                        
                        Text("\(animeNode.node.rank)")
                            .font(.system(size: 16))
                    }
                    VStack(spacing: 2) {
                        Text("Popularity".uppercased())
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 1)
                            .background(RoundedRectangle(cornerRadius: 4).fill(.blue))
                        
                        Text("\(animeNode.node.num_list_users)")
                            .font(.system(size: 16))
                    }
                    
                }
                .font(.caption)
                
                HStack {
                    Menu {
                        Picker(selection: $selectedViewType) {
                            ForEach(ViewMode.allCases) { value in
                                Text(value.rawValue) // use associated string
                                    .tag(value)
                                    .font(.largeTitle)
                            }
                        } label: {}
                    } label: {
                        HStack {
                            Label(selectedViewType.rawValue.capitalized, systemImage: "tv")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 4).fill(.green))
                    }
                    .fixedSize()
                }
                .padding(.top)
                
            }
            .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .border(.orange)
    }
}

struct GenreRow: View {
    let animeNode: AnimeNode
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 4) {
                ForEach(animeNode.node.genres, id: \.name) { tag in
                    Text(tag.name)
                        .font(.caption)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .font(.body)
                        .background(.secondary)
                        .foregroundColor(Color.white)
                        .cornerRadius(3)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .border(.green)
    }
}
