//
//  RepoList.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-06-17.
//

import Foundation
import SwiftUI

struct RepoList: View {
    @EnvironmentObject var tokenManager: TokenManager
    
    let repos: [SearchResult]
    let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"] ?? ""
    let callbackUrl = "ios-github-trending://callback"
    var loggedIn: Bool {
        tokenManager.accessToken != nil
    }
    
    var body: some View {
        let url = "https://github.com/login/oauth/authorize?client_id=\(clientId)&redirect_uri=\(callbackUrl)&scope=user%20public_repo"
        
        VStack {
            if !loggedIn {
                Link(
                    destination: URL(string: url)!) {
                    Text("Login with GitHub")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(40)
                    }
                    .padding()
            }
            
            ForEach(repos) { repo in
                RepoItem(repo: repo)
            }
        }
    }
}

struct RepoList_Previews: PreviewProvider {
    static var previews: some View {
        RepoList(repos: [])
    }
}
