//
//  TrendingReposApp.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-05-02.
//

import SwiftUI

@main
struct TrendingReposApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL { url in
                print(url)
            }
        }
    }
}
