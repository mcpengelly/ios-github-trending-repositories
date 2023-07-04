//
//  RepoItem.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-06-17.
//

import Foundation
import SwiftUI

struct RepoDetailsView: View {
    let repo: SearchResult
    private let MAX_LINES_DESCRIPTION = 4
    private let SINGLE_LINE = 1

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(repo.author)/\(repo.name)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(SINGLE_LINE)

            Text(repo.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .lineLimit(MAX_LINES_DESCRIPTION)

            RepoStats(repo: repo)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 5)
        .stroke(Color.gray, lineWidth: 2))
    }
}

struct RepoItem: View {
    let repo: SearchResult
    let MAX_LINES_DESCRIPTION = 4
    let SINGLE_LINE = 1
    
    var body: some View {
        VStack(alignment: .leading) {
            if let url = URL(string: repo.url) {
                Link(destination: url) {
                    RepoDetailsView(repo: repo)
                }
            } else {
                RepoDetailsView(repo: repo)
            }
        }
    }
}

struct RepoItem_Previews: PreviewProvider {
    static var previews: some View {
        let dummyRepo = SearchResult(
            author: "OpenAI",
            name: "ChatGPT",
            avatar: "lol",
            url: "https://github.com/OpenAI/ChatGPT",
            description: "ChatGPT is a large language model developed by OpenAI.",
            language: "Swift",
            languageColor: "#FF4500",
            stars: 12345,
            forks: 1234,
            currentPeriodStars: 123,
            builtBy: [Contributor(username: "test123", href: "https://github.com", avatar: "ok")]
        )
        
        RepoItem(repo: dummyRepo)
    }
}

