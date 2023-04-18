//
//  ProgressionStepper.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/16/23.
//

import SwiftUI

struct ProgressionStepper: View {
    let item: WeebItem
    @Binding var progress: Float
    var maxEpisodeOrChapter: Int
    
    var body: some View {
        VStack(spacing: 0) {
            Stepper {
                TextField(
                    "Progression",
                    value: $progress,
                    formatter: NumberFormatter(),
                    prompt: Text("0")
                )
                .textFieldStyle(.roundedBorder)
            } onIncrement: {
                handlePlus()
            } onDecrement: {
                handleMinus()
            }
            
            Text("Currently on chapter: \(Int(progress)) / \(maxEpisodeOrChapter)")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.caption)
                .padding(.top)
        }
    }
    
    func handlePlus() {
        progress += 1
    }
    
    func handleMinus() {
        progress = max((progress) - 1, 0)
    }
}

struct ProgressionStepper_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.ui.background
            
            ProgressionStepper(
                item: SampleData.sampleData[0],
                progress: .constant(15.0),
                maxEpisodeOrChapter: 24
            )
        }
        .previewLayout(.sizeThatFits)
        
    }
}
