//
//  TrendingReposViewModel.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-07-08.
//

import SwiftUI

class TrendingReposViewModel: ObservableObject {
    @Published var repos: [SearchResult] = []
    @Published var isLoading: Bool = false
    @Published var selectedTimeFrame: TimeFrame = .daily
    @Published var isError = false
    
    var tokenManager: TokenManager
    var alertManager: AlertManager
    
    init(tokenManager: TokenManager, alertManager: AlertManager) {
        self.tokenManager = tokenManager
        self.alertManager = alertManager
    }

    var loggedIn: Bool {
        tokenManager.accessToken != nil
    }

    func getTrendingRepositories(timeFrame: String) {
        isLoading = true

        NetworkManager.shared.fetchTrendingRepos(timeFrame: timeFrame) { result in
            switch result {
            case .success(let fetchedRepos):
                DispatchQueue.main.async { [self] in
                    Logger.shared.debug("Data received: \(repos)")
                    let sortedRepos = fetchedRepos.sorted { $0.currentPeriodStars > $1.currentPeriodStars }
                    self.repos = sortedRepos
                }
            case .failure(let error):
                Logger.shared.error("\(error)")
                self.alertManager.handle(error: .noData)
            }
            self.isLoading = false
        }
    }
}
