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
            self.title = "No data found."
            self.description = "Unable to fetch trending github data"
            self.showAlert = true
        case .noAuth:
            self.title = "Not authenticated with Github."
            self.description = "You must Login with Github to star Repositories from the app"
            self.showAlert = true
        }
    }
    
    func resetAlert() {
        title = ""
        description = ""
        showAlert = false
    }
}
