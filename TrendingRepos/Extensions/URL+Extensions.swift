//
//  URL+Extensions.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-07-08.
//

import Foundation

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return nil
        }
        
        var parameters = [String: String]()
        queryItems.forEach { parameters[$0.name] = $0.value }
        
        return parameters
    }
}
