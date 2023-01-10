//
//  WatchingButton.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 12/18/22.
//

import SwiftUI

struct WatchingButton: View {
    @Binding var selectedViewType: ViewMode

    var body: some View {
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
    }
}

struct WatchingButton_Previews: PreviewProvider {
    static var previews: some View {
        WatchingButton(selectedViewType: .constant(.completed))
    }
}
