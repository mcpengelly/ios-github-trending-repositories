//
//  AlertManager.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-07-07.
//

import Foundation
import SwiftUI
import Combine

enum ErrorTypes: Error {
    case noData
    case noAuth
}

class AlertManager: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var showAlert: Bool = false

    func handle(error: ErrorTypes) {
        switch error {
        case .noData:
            self.title = NSLocalizedString("no_data_found", comment: "No data Modal")
            self.description = NSLocalizedString("unable_to_fetch_data", comment: "Unable to fetch Data Modal")
            self.showAlert = true
        case .noAuth:
            self.title = NSLocalizedString("not_authenticated", comment: "Not authenticated")
            self.description = NSLocalizedString("login_to_star_repos", comment: "User must be logged in to star")
            self.showAlert = true
        }
    }
    
    func resetAlert() {
        title = ""
        description = ""
        showAlert = false
    }
}
