//
//  RepoModel.swift
//  TrendingRepos
//
//  Created by Matthew Pengelly on 2023-07-23.
//

import Foundation

struct RepoModel {
    let id: UUID
    let name: String
    let author: String
    let description: String
    let stars: Int
    let currentPeriodStars: Int
    let forks: Int
    let avatar: String
    let url: String
    let language: String?
    let languageColor: String?

    init(from searchResult: SearchResult) {
        self.id = searchResult.id
        self.name = searchResult.name
        self.author = searchResult.author
        self.description = searchResult.description
        self.stars = searchResult.stars
        self.currentPeriodStars = searchResult.currentPeriodStars
        self.forks = searchResult.forks
        self.language = searchResult.language
        self.languageColor = searchResult.languageColor
        self.avatar = searchResult.avatar
        self.url = searchResult.url
    }
}
