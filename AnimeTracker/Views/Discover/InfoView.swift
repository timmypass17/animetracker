//
//  InfoSheet.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 3/28/23.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("General Information 🥸")
                .font(.title)
                .bold()
                .padding(.vertical)
            
            Group {
                Text("Q: What are seasonal animes?")
                    .bold()
                Text("A: Seasonal animes are animes released during a particular season, such as winter, spring, summer, or fall. Seasonal anime usually have 12, 13, 24, or 26 episodes. Animes that have 24+ episodes are broken up into two 12 episodes spanning over 2 seasons.")
            }
            
            Divider()
            
            Group {
                Text("Q: What are weekly animes?")
                    .bold()
                Text("A: Weekly animes are usually for longer series. They are released every week without being constrained to a season. They tend to have more fillers and okay animation quality.")
            }
            
            Divider()
            
            Group {
                Text("Q: What are the seasons?")
                    .bold()
                Text("A: Here are all the seasons and months\nWinter: January, February, March\nSpring: April, May, June\nSummer: July, August, September\nFall: October, November, December")
            }
            
            Divider()

            Group {
                Text("Q: Why do some animes have 0 episodes?")
                    .bold()
                Text("A: Animes with 0 episodes are currently ongoing or have not released.")
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.ui.background)
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
