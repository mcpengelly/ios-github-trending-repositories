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
// - rearrange things into folders
// - make repo public
// - launch details
    // - register for apple developer program 99$ USD
    // https://developer.apple.com/programs/enroll/
    // - see app store review guidelines
    // - testflight? how?
    // - app assets:
        // title: Trending Github Projects (ios) - ensure github app has the same name
        // description: Keep up to date with the latest daily, weekly & monthly trending code repositories straight from the source!
        // keywords: github, trending, code, respository, latest, popular, discovery, tools
        // demo: check slack for vid - refilm demo after latest features - refilm demo
        // Web APIs used:
        // 1. Unofficial github trending repositories: https://github.com/alisoft/github-trending-api
        // 2. Official github OAuth, star/unstar repositories on behalf of the user & checking users star status
        // Native APIs:
            // IOS Keychain:
                // fields: githubAccessToken
            // UserDefaults:
                // fields: darkModeEnabled
        // Secrets.plist (to fork/work on the repo you need this setup, you can make your own oauth app)
            // fields: CLIENT_ID & CLIENT_SECRET
        // Features:
            // Finds Trending Projects: Keep up to date with the latest code projects on github at a glance
            // Github Oauth Integeration: Star repositories as though you were on Github.com
            // Dark Mode: Protect your eyes by toggling darkmod within the app. Defaults to your ios setting
            // Open Source: the code is open to everyone and will remain so
            // A11y Compliant: Supports IOS screenreader
            // Internationalization: Supports english, french, german, italian, portugeuse, spanish.
                // If you want more just raise a Github Issue with the requested language.
    // - expect apple review to take 3 business days
    // - upload an archived app file to app store connect - how to generate archived app when time comes?
    // - release automatically or manually (you choose)

// demo 2 target:
// - unit test the most important parts - should be done before refactor, that way we know if the refactor broke anything
// - address all TODOS
// - convert completion handlers to futures
// - filter on programming language if one specified, otherwise all. always default back to all on launch.
// - TokenManager does too much, exclude the parts that have to do with GithubAPI
// - use result wherever applicable to wrap the response value, that way the caller can switch on failure if need.
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
