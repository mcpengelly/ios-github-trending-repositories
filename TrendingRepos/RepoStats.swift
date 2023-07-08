//
//  RepoStats.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-06-17.
//

import Foundation
import SwiftUI

struct RepoStats: View {
    @State var hasStar: Bool = false
    
    var tokenManager: TokenManager
    var alertManager: AlertManager
    var repo: SearchResult
    var githubAPI: GithubAPI
    
    init(repo: SearchResult, tokenManager: TokenManager, alertManager: AlertManager) {
        self.tokenManager = tokenManager
        self.alertManager = alertManager
        self.repo = repo
        self.githubAPI = GithubAPI(tokenManager: self.tokenManager)
    }
    
    func toggleStar() {
        guard tokenManager.getAccessToken() != nil else {
            Logger.shared.debug("You must be signed in to star repos")
            alertManager.handle(error: ErrorTypes.noAuth)
            return
        }
        
        // TODO: debounce, since a user could spam this button to ping network, which could cause undesirable UI
        githubAPI.checkIfRepoStarred(repoOwner: repo.author, repoName: repo.name) { result in
            switch result {
            case .success(let repoStarred):
                DispatchQueue.main.async {
                    guard let isRepoStarred = repoStarred else {
                        Logger.shared.error("Problem occured with checkIsRepoStarred completion handler")
                        return
                    }
                    githubAPI.toggleRepoStar(
                        isRepoStarred: isRepoStarred,
                        repoOwner: repo.author, repoName: repo.name
                    ) { newStarStatus in
                        // use .success and have repoStarred come through?
                        if let starStatus = newStarStatus {
                            Logger.shared.debug("Toggling star status to: \(starStatus)")
                            hasStar = starStatus
                        }
                    }
                }
            case .failure(let error):
                Logger.shared.error("Unable to toggle star while Logged out")
                alertManager.handle(error: error)
            }
        }
    }
    
    var body: some View {
        let filledStarButton = Button(action: toggleStar) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 23))
        }
        let emptyStarButton = Button(action: toggleStar) {
            Image(systemName: "star")
                .font(.system(size: 23))
        }
        
        HStack {
            if hasStar {
                filledStarButton
            } else {
                emptyStarButton
            }
            Text(String(repo.stars))
            Divider()
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("\(repo.currentPeriodStars)")
            }
            .frame(width: 75)
            .foregroundColor(Color.green)
            
            Divider()
            Image(systemName: "arrow.triangle.branch")
            Text(String(repo.forks))
            
            if let language = repo.language {
                Divider()
                Text(language)
                    .foregroundColor(repo.languageColor.map(Color.init(hex:)) ?? Color.black)
            }
            
        }
        .onReceive(tokenManager.$accessToken) { accessToken in
            if accessToken != nil {
                checkIfRepoStarred()
            } else {
                self.hasStar = false // if nil, user has just logged out
            }
        }
        .padding(2)
        .font(.system(size: 16))
        .foregroundColor(.gray)
        .lineLimit(1)
    }
    
    private func checkIfRepoStarred() {
        githubAPI.checkIfRepoStarred(repoOwner: repo.author, repoName: repo.name) { result in
            switch result {
            case .success(let isStarred):
                DispatchQueue.main.async {
                    self.hasStar = isStarred ?? false
                }
            case .failure(let error):
                Logger.shared.error("Error checking if repo starred \(error)")
                alertManager.handle(error: error)
            }
        }
    }
    
    private func updateStarStatus() {
        if tokenManager.getAccessToken() != nil {
            checkIfRepoStarred()
        } else {
            self.hasStar = false
        }
    }
    
    struct RepoStats_Previews: PreviewProvider {
        static var previews: some View {
            let dummyRepo = SearchResult(
                author: "OpenAI",
                name: "ChatGPT",
                avatar: "ok",
                url: "https://github.com/OpenAI/ChatGPT",
                description: "ChatGPT is a large language model developed by OpenAI.",
                language: "Swift",
                languageColor: "#FF4500",
                stars: 12345,
                forks: 1234,
                currentPeriodStars: 123,
                builtBy: [Contributor(username: "test123", href: "https://github.com", avatar: "ok")]
            )
            
            // TODO: replace with actual mocks?
            let mockTokenManager = TokenManager()
            let mockAlertManager = AlertManager()
            let mockViewModel = TrendingReposViewModel(tokenManager: mockTokenManager, alertManager: mockAlertManager)
            
            ContentView(viewModel: mockViewModel)
                .environmentObject(mockTokenManager)
                .environmentObject(mockAlertManager)
            
            RepoStats(repo: dummyRepo, tokenManager: mockTokenManager, alertManager: mockAlertManager)
        }
    }
}
