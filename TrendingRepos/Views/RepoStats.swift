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
    
    var darkModeManager: DarkModeManager
    var tokenManager: TokenManager
    var alertManager: AlertManager
    var repo: RepoModel
    var githubAPI: GithubAPI
    
    init(repo: RepoModel, tokenManager: TokenManager, alertManager: AlertManager, darkModeManager: DarkModeManager) {
        self.tokenManager = tokenManager
        self.alertManager = alertManager
        self.repo = repo
        self.githubAPI = GithubAPI(tokenManager: self.tokenManager)
        self.darkModeManager = darkModeManager
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
        
//        let accessibilityLabel =
//        "Total Stars: \(String(repo.stars)), " +
//            "number of stars since period: \(repo.currentPeriodStars), " +
//            "total forks: \(repo.forks), coding language used: \(repo.language ?? "Unknown")"
//
        let accessibilityLabel = String(format: NSLocalizedString("repo_accessibility_label", comment: ""),
            String(repo.stars),
            String(repo.currentPeriodStars),
            String(repo.forks),
            repo.language ?? NSLocalizedString("unknown_language", comment: "")
        )
        
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
        .accessibilityLabel(accessibilityLabel)
        .onReceive(tokenManager.$accessToken) { accessToken in
            if accessToken != nil {
                checkIfRepoStarred()
            } else { // if nil, user has just logged out
                self.hasStar = false
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
            let dummyRepo = RepoModel(from: SearchResult(
                author: "OpenAI",
                name: "ChatGPT",
                avatar: "ok",
                url: "https://github.com/OpenAI/ChatGPT",
                description: "ChatGPT is a large language model developed by OpenAI.",
                language: "Swift",
                languageColor: "#FF4500",
                stars: 12345,
                forks: 1234,
                currentPeriodStars: 123
//                builtBy: [Contributor(username: "test123", href: "https://github.com", avatar: "ok")]
            )
          )
            
            // TODO: replace with actual mocks?
            let mockTokenManager = TokenManager()
            let mockAlertManager = AlertManager()
            let darkModeManager = DarkModeManager()
            let mockViewModel = TrendingReposViewModel(tokenManager: mockTokenManager, alertManager: mockAlertManager)
            
            ContentView(viewModel: mockViewModel, darkModeManager: darkModeManager)
                .environmentObject(mockTokenManager)
                .environmentObject(mockAlertManager)
            
            RepoStats(repo: dummyRepo, tokenManager: mockTokenManager, alertManager: mockAlertManager, darkModeManager: darkModeManager)
        }
    }
}
