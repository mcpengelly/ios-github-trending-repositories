//
//  TimeFrame.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-07-08.
//

enum TimeFrame: String, CaseIterable {
    // use keys here instead and on View map them to values
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    
    func previous() -> TimeFrame {
        guard let index = TimeFrame.allCases.firstIndex(of: self) else { return self }
        let newIndex = index == 0 ? TimeFrame.allCases.count - 1 : index - 1
        return TimeFrame.allCases[newIndex]
    }
    
    func next() -> TimeFrame {
        guard let index = TimeFrame.allCases.firstIndex(of: self) else { return self }
        let newIndex = (index + 1) % TimeFrame.allCases.count
        return TimeFrame.allCases[newIndex]
    }
}
