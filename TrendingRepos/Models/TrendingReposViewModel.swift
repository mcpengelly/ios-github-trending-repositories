//
//  TrendingReposViewModel.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-07-08.
//

import SwiftUI

class TrendingReposViewModel: ObservableObject {
    @Published var repos: [RepoModel] = []
    @Published var isLoading: Bool = false
    @Published var selectedTimeFrame: TimeFrame = .daily
    @Published var isError = false
    
    var tokenManager: TokenManager
    var alertManager: AlertManager
    var networkManager: NetworkManager
    
    init(tokenManager: TokenManager, alertManager: AlertManager, networkManager: NetworkManager = NetworkManager.shared) {
        self.tokenManager = tokenManager
        self.alertManager = alertManager
        self.networkManager = networkManager
    }
    
    var loggedIn: Bool {
        tokenManager.accessToken != nil
    }
    
    func getTrendingRepositories(timeFrame: String) {
        isLoading = true
        
        networkManager.fetchTrendingRepos(timeFrame: timeFrame) { result in
            switch result {
            case .success(let fetchedRepos):
                DispatchQueue.main.async { [self] in
                    Logger.shared.debug("Data received: \(repos)")
                    let sortedRepos = fetchedRepos.sorted { $0.currentPeriodStars > $1.currentPeriodStars }
                    self.repos = sortedRepos.map {RepoModel(from: $0)}
                }
            case .failure(let error):
                Logger.shared.error("\(error)")
                self.alertManager.handle(error: .noData)
                DispatchQueue.main.async { [self] in
                    isError = true
                }
            }
            
            DispatchQueue.main.async { [self] in
                self.isLoading = false
            }
        }
    }
}
