//
//  TrendingReposApp.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-05-02.
//

// demo target:
// - verify accessibility with physical device
    // - see app store review guidelines
    // - testflight? how?
    // - app metadata:
        // title: Trending Github Projects
        // description: Keep up to date with the latest daily, weekly & monthly trending code repositories straight from the source!
        // keywords: github, trending, code, respository, latest, popular, discovery, tools
    // - upload an archived app file to app store connect - how to generate archived app when time comes?
    // - release automatically or manually (you choose)


import SwiftUI

@main
struct TrendingReposApp: App {
    @StateObject private var tokenManager = TokenManager()
    @StateObject private var alertManager = AlertManager()
    @StateObject private var darkModeManager = DarkModeManager()
    
    var viewModel = TrendingReposViewModel(tokenManager: TokenManager(), alertManager: AlertManager())
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel, darkModeManager: darkModeManager)
                .environmentObject(tokenManager)
                .environmentObject(alertManager)
                .environmentObject(darkModeManager)
                .onOpenURL { url in
                    if let code = url.queryParameters?["code"] {
                        // TODO: callback hell? use futures?
                        tokenManager.requestAccessToken(authCode: code) { accessToken in
                            if let token = accessToken?.accessToken {
                                tokenManager.setAccessToken(token)
                            }
                        }
                    }
                }
        }
    }
}
