//
//  DarkModeManager.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-07-09.
//

import Foundation
import UIKit // TODO: bad idea to mix in UIKit in with an app thats 99% swiftUI?

class DarkModeManager: ObservableObject {
    @Published var darkModeEnabled: Bool

    init() {
        // UserDefaults instead of Keychain
        if let darkMode = UserDefaults.standard.object(forKey: "darkModeEnabled") as? Bool {
            self.darkModeEnabled = darkMode
        } else {
            // Determine the users darkMode state for ios device, if its not dark, we arent in darkMode.
            self.darkModeEnabled = UITraitCollection.current.userInterfaceStyle == .dark
        }
    }
    
    func toggleDarkMode() {
        // Toggle darkModeEnabled
        darkModeEnabled = !darkModeEnabled
        // Save the new state to UserDefaults
        UserDefaults.standard.set(darkModeEnabled, forKey: "darkModeEnabled")
        Logger.shared.debug("toggled darkMode")
    }
}
