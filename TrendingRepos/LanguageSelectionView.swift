//
//  LanguageSelectionView.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-07-14.
//

import Foundation
import SwiftUI

struct LanguageSelectionView: View {
    let languages = ["English", "Spanish", "French", "German", "Italian", "Portugese"] // Replace with your language options
    
    @State private var selectedLanguage = "English" // Initial language selection
    
    var body: some View {
        VStack {
            Picker(selection: $selectedLanguage, label: Text("Select Language")) {
                ForEach(languages, id: \.self) { language in
                    Text(language)
                }
            }
            .onChange(of: selectedLanguage) { newLanguage in
                // Perform an action or call a method when the language selection changes
                Logger.shared.debug("Picker selected: \(newLanguage)")
                handleLanguageSelection(newLanguage)
            }
            .pickerStyle(.menu) // Use .wheel for a spinning wheel style
        }
        .padding()
    }
    
    func handleLanguageSelection(_ selectedLanguage: String) {
        LocalizationManager.shared.setLanguage(selectedLanguage)
    }
}
