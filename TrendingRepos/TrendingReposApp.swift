//
//  TrendingReposApp.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-05-02.
//

// demo targets:
// - ContentView does too much, use MVVM pattern
// - debug friendly error handling
// - user friendly errors
// - unit testing the most important parts
// - swiftlint integration
// - convert to futures instead of callbacks
// - launch details
// - double check to make sure access_token isnt unsecurely stored for any reason, for example to update ui
// - TokenManager does too much, exclude the parts that have to do with GithubAPI

// demo 2 targets:
// - ctrl F "TODO"
// - introduce abstractions over ThreadQueue.main.dataTask in NetworkManager?
// - debug logging
// - dark mode

import SwiftUI

struct TokenInfo {
    var access_token: String
    var scope: String
    var token_type: String
}

@main
struct TrendingReposApp: App {
    @StateObject private var tokenManager = TokenManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tokenManager)
                .onOpenURL { url in
                    if let code = url.queryParameters?["code"] {
                        // TODO: callback hell?
                        tokenManager.requestAccessToken(authCode: code) { accessToken in
                            if let token = accessToken?.access_token {
                                tokenManager.setAccessToken(token)
                            }
                        }
                    }
                }
        }
    }
}
