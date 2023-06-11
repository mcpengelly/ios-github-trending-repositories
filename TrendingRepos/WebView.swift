//
//  WebView.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-05-14.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let request: URLRequest

    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let something = uiView.load(request)
        print("something", something!)
        
        
    }
}
