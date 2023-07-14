//
//  SecretHelper.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-07-14.
//

import Foundation

func valueForSecretKey(named key: String) -> String? {
    guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
        let plist = NSDictionary(contentsOfFile: filePath),
        let value = plist.object(forKey: key) as? String else {
        return nil
    }
    
    return value
}
