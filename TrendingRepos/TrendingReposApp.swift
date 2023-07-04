//
//  TrendingReposApp.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-05-02.
//

// demo targets:
// - securely store access_token in keychain after fetch
// - restore access_token from keychain on launch, when applicable, otherwise use existing login flow
// - user friendly errors

// demo 2 targets:
// - dark mode

// all todos:
// - TokenManager does too much
// - ContentView does too much, use MVVM pattern
// - introduce abstractions over ThreadQueue.main.dataTask in NetworkManager? - in progress. doesnt work as i expect immediately - still cant get this to work, backend responds with 403 or 401... but im providing bearer token?
// - debug logging?

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
