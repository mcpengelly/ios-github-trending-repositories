//
//  TrendingReposApp.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-05-02.
//

// demo target:
// access token:
// - do not set the accessToken when switching between pages
// - do not set the accessToken in storage if it was just pulled from storage
// - double check to make sure access_token isnt unsecurely stored for any reason, for example to update ui

// - unit testing the most important parts: in progress
// - launch details

// demo 2 target:
// - convert to futures instead of callbacks
// - introduce abstractions over ThreadQueue.main.dataTask in NetworkManager?
// - TokenManager does too much, exclude the parts that have to do with GithubAPI
// - dark mode
// - use result wherever applicable

import SwiftUI

struct TokenInfo {
    var accessToken: String
    var scope: String
    var tokenType: String
}

@main
struct TrendingReposApp: App {
    @StateObject private var tokenManager = TokenManager()
    @StateObject private var alertManager = AlertManager()
    var viewModel = TrendingReposViewModel(tokenManager: TokenManager(), alertManager: AlertManager())
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .environmentObject(tokenManager)
                .environmentObject(alertManager)
                .onOpenURL { url in
                    if let code = url.queryParameters?["code"] {
                        // TODO: callback hell?
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
