//
//  TrendingReposApp.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-05-02.
//

// demo target:
// - verify accessibility with physical device
// - final pass physical device test:
    // all tabs, all translations, accessibility mode on/off, dark mode persisting state, loggout and loggedin states
// - launch details
    // - register for apple developer program 99$ USD
    // https://developer.apple.com/programs/enroll/
    // - see app store review guidelines
    // - testflight?
    // - app assets:
        // title: Trending Github Projects (ios)
        // description: Keep up to date with the latest daily, weekly & monthly trending code repositories straight from the source!
        // keywords: github, trending, code, respository, latest, popular, discovery, tools
        // demo: check slack for vid - refilm demo after latest features
        // Web APIs used:
        // 1. unofficial github trending repositories: https://github.com/alisoft/github-trending-api
        // 2. official github OAuth, star/unstar repositories on behalf of the user & checking users star status
        // Native APIs:
            // IOS Keychain
                // fields: githubAccessToken & darkModeEnabled
        // Secrets.plist, to fork/work on the repo you need this setup.
            // CLIENT_ID and CLIENT_SECRET
    // - expect apple review to take 3 business days
    // - upload an archived app file to app store connect - how to generate archived app when time comes?
    // - release automatically or manually (you choose)

// demo 2 target:
// - buy me a coffee button
// - unit testing the most important parts: in progress
// - convert to futures instead of callbacks
// - filter on programming language if one specified, otherwise all. always default back to all on launch.
// - introduce abstractions over ThreadQueue.main.dataTask in NetworkManager?
// - TokenManager does too much, exclude the parts that have to do with GithubAPI
// - use result wherever applicable
// - address all TODOS
// - nav bar hides when reaching the bottom - couldnt fix when i tried

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
