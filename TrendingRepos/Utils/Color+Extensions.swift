//
//  Color+Extensions.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-07-08.
//

// Easily create a Color from a hex value
import SwiftUI

extension Color {
    init?(hex: String) {
        let formattedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgbValue: UInt64 = 0
        
        guard Scanner(string: formattedHex).scanHexInt64(&rgbValue),
              formattedHex.count == 6 else {
            return nil
        }
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(UIColor(red: red, green: green, blue: blue, alpha: 1.0))
    }
}
