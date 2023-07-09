//
//  TrendingReposApp.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-05-02.
//

// demo target:
// access token:
// - double check to make sure access_token isnt logged, or in local memory unnecessarily
// - launch details
    // - test on physical device
    // - check contractual agreement, am i allowed to release free shit? pending discussion with work
    // - register for apple developer program 99$ USD. any way to know if theyll accept it before paying?
    // - see app store review guidelines
    // - testflight?
    // - app assets:
        // title: trending github repos (ios)
        // description: Follow the latest daily, weekly & monthly trending code repositories straight from the source!
        // keywords: github, trending, code, respository, latest, popular
        // demo: check slack for vid
        // Web APIs used:
        // 1. unofficial github trending repositories
        // 2. official github OAuth, star/unstar repositories on behalf of the user & checking users star status
        // Native APIs: IOS Keychain: githubAccessToken & darkModeEnabled
    // - expect apple review to take 48 hours
    // - upload an archived app file to app store connect - how to generate archived app when time comes?
    // - release automatically or manually (you choose)
// **** double check the app is still working as expected after everything ****

// demo 2 target:
// - buy me a coffee button
// - unit testing the most important parts: in progress
// - convert to futures instead of callbacks
// - introduce abstractions over ThreadQueue.main.dataTask in NetworkManager?
// - TokenManager does too much, exclude the parts that have to do with GithubAPI
// - use result wherever applicable
// - address all TODOS
// - accessibility
// - 

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
