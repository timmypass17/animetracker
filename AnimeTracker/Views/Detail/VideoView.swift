//
//  VideoView.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 4/4/23.
//

import Foundation
import SwiftUI
import WebKit

struct VideoView: UIViewRepresentable {
    let youtubeUrl: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: youtubeUrl) else { return }
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: url))
    }
}
