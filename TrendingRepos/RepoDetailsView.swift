//
//  RepoDetailsView.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-07-05.
//

import Foundation
import SwiftUI

struct RepoDetailsView: View {
    @EnvironmentObject var tokenManager: TokenManager
    @EnvironmentObject var alertManager: AlertManager
    
    let repo: SearchResult

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(repo.author)/\(repo.name)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(Constants.Layout.singleLine)

            Text(repo.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .lineLimit(Constants.Layout.multiLine)

            RepoStats(repo: repo, tokenManager: tokenManager, alertManager: alertManager)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 5)
        .stroke(Color.gray, lineWidth: 2))
    }
}
