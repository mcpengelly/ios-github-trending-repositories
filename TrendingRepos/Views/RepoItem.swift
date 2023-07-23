//
//  RepoItem.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-06-17.
//

import Foundation
import SwiftUI

struct RepoItem: View {
    let repo: RepoModel
    var body: some View {
        VStack(alignment: .leading) {
            if let url = URL(string: repo.url) {
                Link(destination: url) {
                    RepoDetails(repo: repo)
                }
            } else {
                RepoDetails(repo: repo)
            }
        }
    }
}

struct RepoItem_Previews: PreviewProvider {
    static var previews: some View {
        let dummyRepo = RepoModel(from: SearchResult(
                author: "OpenAI",
                name: "ChatGPT",
                avatar: "lol",
                url: "https://github.com/OpenAI/ChatGPT",
                description: "ChatGPT is a large language model developed by OpenAI.",
                language: "Swift",
                languageColor: "#FF4500",
                stars: 12345,
                forks: 1234,
                currentPeriodStars: 123
            )
        )
        
        RepoItem(repo: dummyRepo)
    }
}

