//
//  RepoDetailsView.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-07-05.
//

import Foundation
import SwiftUI

struct RepoDetails: View {
    @EnvironmentObject var tokenManager: TokenManager
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var darkModeManager: DarkModeManager
    
    let repo: RepoModel
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(repo.author)/\(repo.name)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(Constants.Layout.singleLine)
            
            Text(repo.description.isEmpty ? NSLocalizedString("repo_no_description", comment: "No description for item") : repo.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .lineLimit(Constants.Layout.multiLine)
            
            RepoStats(repo: repo, tokenManager: tokenManager, alertManager: alertManager, darkModeManager: darkModeManager)
        }
        .accessibilityLabel("\(repo.author)/\(repo.name), \(repo.description)")
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 5) 
            .fill(darkModeManager.darkModeEnabled ? Color(.black) : Color(.white))
            .border(Color(.gray))
        )
    }
}
                    
