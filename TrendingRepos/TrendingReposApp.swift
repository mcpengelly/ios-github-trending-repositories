//
//  TrendingReposApp.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-05-02.
//

// demo target:
// - ContentView does too much, use MVVM pattern
// - graceful error handling for users
// - unit testing the most important parts: in progress
// - convert to futures instead of callbacks
// - launch details
// - double check to make sure access_token isnt unsecurely stored for any reason, for example to update ui
// - do not set the accessToken in storage if it was just pulled from storage
// - TokenManager does too much, exclude the parts that have to do with GithubAPI

// demo 2 target:
// - introduce abstractions over ThreadQueue.main.dataTask in NetworkManager?
// - dark mode

import SwiftUI

struct TokenInfo {
    var accessToken: String
    var scope: String
    var tokenType: String
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
                            if let token = accessToken?.accessToken {
                                tokenManager.setAccessToken(token)
                            }
                        }
                    }
                }
        }
    }
}
