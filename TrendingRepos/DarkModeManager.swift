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
        if let darkMode = KeychainHelper.getBool("darkModeEnabled") {
            self.darkModeEnabled = darkMode
        } else {
            // Determine the users darkMode state for ios device, if its not dark, we arent in darkMode.
            self.darkModeEnabled = UITraitCollection.current.userInterfaceStyle == .dark
        }
    }
    
    func toggleDarkMode() {
        var success: Bool
        // pull darkMode config from the keychain if possible
        if let darkMode = KeychainHelper.getBool("darkModeEnabled") {
            Logger.shared.debug("Found keychain darkModeEnabled, toggling...")
            success = KeychainHelper.setBool("darkModeEnabled", value: !darkMode)
            darkModeEnabled = !darkMode
        } else {
            Logger.shared.debug("No Keychain darkModeEnabled found. Toggling default")
            success = KeychainHelper.setBool("darkModeEnabled", value: !darkModeEnabled)
            darkModeEnabled = !darkModeEnabled
        }
        if success { Logger.shared.debug("toggled darkMode") }
    }
}
