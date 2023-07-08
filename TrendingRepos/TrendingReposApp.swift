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
    // - check contractual agreement, am i allowed to release free shit?
    // - register ror apple developer program 99$ USD, and they may not even accept my app lmao.
    // - test on device
    // - testflight?
    // - app assets: icon, title, description, keywords, demo video
    // - list used APIS: unofficial github trending, official github Oauth & star/unstar repositories
    // - see app store review guidelines
    // - expect review to take time
    // - upload an archived app file to app store fonnect
    // - release automatically or manually (you choose)
// **** double check the app is still working as expected after everything ****

// demo 2 target:
// - unit testing the most important parts: in progress
// - convert to futures instead of callbacks
// - introduce abstractions over ThreadQueue.main.dataTask in NetworkManager?
// - TokenManager does too much, exclude the parts that have to do with GithubAPI
// - dark mode
// - use result wherever applicable

import SwiftUI

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
