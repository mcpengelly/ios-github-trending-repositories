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
// - make repo public - ask for feedback?
// - launch checklist
    // - see app store review guidelines
    // - testflight? how?
    // - app metadata:
        // title: Trending Github Projects
        // description: Keep up to date with the latest daily, weekly & monthly trending code repositories straight from the source!
        // keywords: github, trending, code, respository, latest, popular, discovery, tools
        // demo: check slack for vid - refilm demo after latest features - refilm demo
        // Web APIs used:
        // 1. Unofficial github trending repositories: https://github.com/alisoft/github-trending-api
            // Lists github repositories by recent popularity; Unofficial Github Trending API was used to access trending repositories data which are not available through official Github APIs.
        // 2. Official login with Github (via OAuth), star/unstar repositories on behalf of the user & checking users star status
        // Native APIs:
            // IOS Keychain:
                // fields: githubAccessToken: We securely store the users access token so the user can be authenticated when they reopen the app after closing it.
            // UserDefaults:
                // fields: darkModeEnabled: we store the users preference for dark mode so they only need to set it one time. By default the
// Secrets.plist (to fork/work on the repo you need this setup, you can make your own oauth app)
    // fields: CLIENT_ID & CLIENT_SECRET
        // Features:
            // Finds Trending Projects: Keep up to date with the latest code projects on github at a glance
            // Github Oauth Integeration: Star repositories as though you were on Github.com
            // Dark Mode: Protect your eyes by toggling darkmode within the app. Defaults to your ios preference
            // Open Source: the code is open to everyone and will remain that way
            // A11y Compliant: Supports IOS screenreader
            // Internationalization: Supports English, French, German, Italian, Portugeuse, Spanish languages. Configured via IOS settings
    // - upload an archived app file to app store connect - how to generate archived app when time comes?
    // - release automatically or manually (you choose)

// demo 2 target:
// - unit test the most important parts - should be done before refactoring, that way we know if the refactor broke anything
// - filter on programming language if one specified, otherwise all. always default back to all on launch.
// - TokenManager does too much, exclude the parts that have to do with GithubAPI
// - convert completion handlers to futures
// - address all TODOS
// - use Result to wrap response values, that way the caller can switch on failure if need.
// - introduce abstractions over ThreadQueue.main.dataTask in NetworkManager?
// - coffee?

// known bugs - wont fix:
    // - nav bar hides when reaching the bottom
    // - nav bar hides when transitioning screens

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
