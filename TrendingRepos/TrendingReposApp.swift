//
//  TrendingReposApp.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-05-02.
//

// demo targets:
// - debug friendly error handling
// - user friendly errors
// - launch details

// demo 2 targets:
// - TokenManager does too much
// - ContentView does too much, use MVVM pattern
// - dark mode
// - ctrl F "TODO"
// - introduce abstractions over ThreadQueue.main.dataTask in NetworkManager?
// - debug logging
// - unit testing
// - swiftlint integration

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
                        print("Authcode: \(code)")
                        // TODO: callback hell?
                        tokenManager.requestAccessToken(authCode: code) { accessToken in
                            if let token = accessToken?.access_token {
                                print("Access Token: \(token)")
                                tokenManager.setAccessToken(token)
                            }
                        }
                    }
                }
        }
    }
}
