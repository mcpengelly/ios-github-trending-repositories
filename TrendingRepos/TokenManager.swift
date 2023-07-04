//
//  TokenManager.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-06-24.
//
import Foundation

class TokenManager: ObservableObject {
    @Published var accessToken: String? = nil
    
    func setAccessToken(_ token: String) {
        DispatchQueue.main.async { [self] in
            // save token to ios keychain
            if KeychainHelper.set("githubAccessToken", value: token) {
                // now we ensure the UI triggers an update for token
                //TODO: might be able to remove now
                self.accessToken = token
            } else {
                print("something went wrong in setAccessToken")
            }
        }
    }
    
    func getAccessToken() -> String? {
        if let token = KeychainHelper.get("githubAccessToken") {
           print("getting access token \(token)")
           return token
        }
        return nil
    }
    
    func clearAccessToken() {
        DispatchQueue.main.async { [self] in
            self.accessToken = nil
        }
    }
    
    //TODO: refactor out generic request handler stuff
    func checkIfRepoStarred(repoOwner: String, repoName: String, completion: @escaping (Bool?) -> Void){
        guard let token = self.getAccessToken() else {
            print("checkIfRepoStarred, token is nil. Something went wrong")
            return
        }
        
        let urlString = "https://api.github.com/user/starred/\(repoOwner)/\(repoName)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // REQUIRED
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                // 404 is the not starred case, 204 is the starred case
                if response.statusCode == 204 {
                    print("Repository status: starred.")
                    // TODO: use completion handler .success instead
                    completion(true)
                } else {
                    print("Repository status: not starred.")
                    completion(false)
                }
            }
        }.resume()
    }
    
    // stars a repo if it hasnt been already, otherwise unstars it
    func toggleRepoStar(isRepoStarred: Bool, repoOwner: String, repoName: String, completion: @escaping (Bool?) -> Void) {
        if let accessToken = self.getAccessToken() {
            let urlString = "https://api.github.com/user/starred/\(repoOwner)/\(repoName)"
            guard let url = URL(string: urlString) else {
                print("Invalid URL \(urlString), check if the repo exists at github.com/\(repoOwner)/\(repoName)")
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
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    print("toggle star responseCode \(response.statusCode)")
                    if response.statusCode == 204 {
                        if isRepoStarred {
                            print("Repository unstarred successfully.")
                            completion(false)
                        } else {
                            print("Repository starred successfully.")
                            completion(true)
                        }
                    } else {
                        completion(false)
                        print("Failed to toggle repository star.")
                    }
                }
            }.resume()
        } else {
            print("ToggleRepoStar: Access token is not yet available")
        }
    }
    
    func requestAccessToken(authCode: String, completion: @escaping (TokenInfo?) -> Void) {
        guard let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"],
              let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"] else {
            print("check your environment config, CLIENT_ID or CLIENT_SECRET are missing")
            return
        }
        
        guard let url = URL(string: "https://github.com/login/oauth/access_token") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // REQUIRED
        
        let parameters: [String: String] = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": authCode
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { [self] data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                if let tokenInfo = self.parseAccessToken(from: data) {
                    DispatchQueue.main.async { [self] in
                        self.setAccessToken(tokenInfo.access_token)
                        completion(tokenInfo)
                    }
                    return
                } else {
                    print("Failed to parse access token", data)
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func parseAccessToken(from data: Data) -> TokenInfo? {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let accessToken = json["access_token"] as? String,
           let scope = json["scope"] as? String,
           let token_type = json["token_type"] as? String {
            return TokenInfo(access_token: accessToken, scope: scope, token_type: token_type)
        } else {
            print("Failed to parse access token:", String(data: data, encoding: .utf8) ?? "")
            return nil
        }
    }
}
