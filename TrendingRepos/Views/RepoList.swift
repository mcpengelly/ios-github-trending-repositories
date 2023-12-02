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
    let disclaimerText = NSLocalizedString("github_thirdparty_disclaimer", comment: "Third-party GitHub disclaimer")

    let repos: [RepoModel]
    var footer: some View {
        Group {
            Text(disclaimerText)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
    let clientId = valueForSecretKey(named: "CLIENT_ID") ?? ""
    let callbackUrl = "ios-github-trending://callback"
    var loggedIn: Bool {
        tokenManager.accessToken != nil
    }
    
    var body: some View {
        let githubAuthURL = "https://github.com/login/oauth/authorize?client_id=\(clientId)&redirect_uri=\(callbackUrl)&scope=user%20public_repo"
        
        VStack {
            if !loggedIn {
                Link(
                    destination: URL(string: githubAuthURL)!) {
                    Text(NSLocalizedString("login_with_github", comment: "github oauth button"))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(40)
                    }
                    .padding()
            }
            
            ForEach(repos, id: \.id) { repo in
                RepoItem(repo: repo)
            }
            
            footer
        }
    }
}

struct RepoList_Previews: PreviewProvider {
    static var previews: some View {
        RepoList(repos: [])
    }
}
