//
//  GithubAPI.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-07-08.
//

import Foundation
import SwiftUI

class GithubAPI {
    var tokenManager: TokenManager
    
    init(tokenManager: TokenManager) {
        self.tokenManager = tokenManager
    }
    
    // TODO: refactor out generic request handler stuff
    func checkIfRepoStarred(repoOwner: String, repoName: String, completion: @escaping (Result<Bool?, ErrorTypes>) -> Void) {
        guard let token = tokenManager.getAccessToken() else {
            Logger.shared.error("token is not availabe, cannot check repo status without auth.")
            return
        }
        
        guard let url = URL(string: "https://api.github.com/user/starred/\(repoOwner)/\(repoName)") else {
            Logger.shared.debug("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // REQUIRED
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                Logger.shared.error("Failed to check if repository starred. Error: \(error)")
                completion(.failure(.noData))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                // 404 is the not starred case, 204 is the starred case
                if response.statusCode == 204 {
                    Logger.shared.debug("Repository status: starred")
                    // TODO: use completion handler .success with a boolean variable inside?
                    completion(.success(true))
                } else {
                    Logger.shared.debug("Repository status: not starred")
                    // TODO: use completion handler .success with a boolean variable inside?
                    completion(.success(false))
                }
            } else {
                Logger.shared.error("No response data")
                completion(.failure(.noData))
            }
        }.resume()
    }
    
    // stars a repo if it hasnt been already, otherwise unstars it
    func toggleRepoStar(isRepoStarred: Bool, repoOwner: String, repoName: String, completion: @escaping (Bool?) -> Void) {
        guard let accessToken = tokenManager.getAccessToken() else {
            Logger.shared.error("accessToken could not be found, cannot star/unstar repo without authentication")
            return
        }
        
        let urlString = "https://api.github.com/user/starred/\(repoOwner)/\(repoName)"
        guard let url = URL(string: urlString) else {
            Logger.shared.debug("Invalid URL \(urlString), check if the repo exists at github.com/\(repoOwner)/\(repoName)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isRepoStarred ? "DELETE" : "PUT"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // REQUIRED
        if !isRepoStarred {
            request.setValue("0", forHTTPHeaderField: "Content-Length") // recommended in docs for PUT
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                Logger.shared.error("Error: \(error)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                // both star and unstar will return 204
                Logger.shared.debug("Status code: \(response.statusCode)")
                if response.statusCode == 204 {
                    if isRepoStarred {
                        Logger.shared.debug("Repo unstarred successfully")
                        // TODO: use completion handler .success instead
                        completion(false)
                    } else {
                        Logger.shared.debug("Repo starred successfully")
                        // TODO: use completion handler .success instead
                        completion(true)
                    }
                } else {
                    completion(false)
                    // TODO: use completion handler .failure instead
                    Logger.shared.error("Failed to toggle respository star")
                }
            }
        }.resume()
    }
}
