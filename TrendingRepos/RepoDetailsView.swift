//
//  RepoDetailsView.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-07-05.
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
