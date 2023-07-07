//
//  RepoStats.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-06-17.
//

import Foundation
import SwiftUI

struct RepoStats: View {
    @EnvironmentObject var tokenManager: TokenManager
    @State var hasStar: Bool = false
    
    let repo: SearchResult
    
    func toggleStar() {
        guard tokenManager.getAccessToken() != nil else {
            Logger.shared.debug("You must be signed in to star repos")
            // TODO: better UX, modal or toast popup? how can we trigger the error modal from here?
            return
        }
        
        //TODO: debounce, since a user could spam this button to ping network, which could cause undesirable UI
        // strictly necessary?
        tokenManager.checkIfRepoStarred(repoOwner: repo.author, repoName: repo.name) { repoStarred in
            DispatchQueue.main.async {
                guard let isRepoStarred = repoStarred else {
                    Logger.shared.error("Problem occured with checkIsRepoStarred completion handler")
                    return
                }
                tokenManager.toggleRepoStar(isRepoStarred: isRepoStarred, repoOwner: repo.author, repoName: repo.name) { newStarStatus in
                    if let starStatus = newStarStatus {
                        Logger.shared.debug("Toggling star status to: \(starStatus)")
                        hasStar = starStatus
                    }
                }
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
            }
        }
        .padding(2)
        .font(.system(size: 16))
        .foregroundColor(.gray)
        .lineLimit(1)
    }
    
    private func checkIfRepoStarred() {
        tokenManager.checkIfRepoStarred(repoOwner: repo.author, repoName: repo.name) { isStarred in
            DispatchQueue.main.async {
                self.hasStar = isStarred ?? false
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
            
            RepoStats(repo: dummyRepo)
        }
    }
    
}

