//
//  TokenManager.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-06-24.
//
import Foundation

class TokenManager: ObservableObject {
    @Published var accessToken: String? // Published ensures the UI updates occur for those relying on this
    
    func setAccessToken(_ token: String) {
        DispatchQueue.main.async { [self] in
            // Save token to ios keychain
            Logger.shared.debug("Setting Users Github access token in their IOS Keychain")
            if KeychainHelper.set("githubAccessToken", value: token) {
                self.accessToken = token
            } else {
                Logger.shared.error("Something went wrong when setting the Access Token on IOS Keychain")
            }
        }
    }
    
    func getAccessToken() -> String? {
        if let token = KeychainHelper.get("githubAccessToken") {
            return token
        }
        return nil
    }
    
    func clearAccessToken() {
        DispatchQueue.main.async { [self] in
            self.accessToken = nil
        }
    }
    
    func requestAccessToken(authCode: String, completion: @escaping (TokenInfo?) -> Void) {
        guard let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"],
              let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"] else {
            Logger.shared.debug("Check your xcode environment config, CLIENT_ID or CLIENT_SECRET are missing")
            return
        }
        
        guard let url = URL(string: "https://github.com/login/oauth/access_token") else {
            Logger.shared.debug("Invalid accessToken URL")
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
        
        URLSession.shared.dataTask(with: request) { [self] data, _, error in
            if let error = error {
                // TODO: use completion handler .failure instead)
                Logger.shared.error("Error fetching access token: \(error)")
                return
            }
            
            if let data = data {
                if let tokenInfo = self.parseAccessToken(from: data) {
                    DispatchQueue.main.async { [self] in
                        // TODO: use completion handler .success instead)
                        self.setAccessToken(tokenInfo.accessToken)
                        Logger.shared.debug("Access token: \(tokenInfo.accessToken)")
                        completion(tokenInfo)
                    }
                    return // TODO: what is this here for?
                } else {
                    // TODO: use completion handler .failure instead)
                    Logger.shared.error("access token could not be parsed from data: \(data)")
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func parseAccessToken(from data: Data) -> TokenInfo? {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let accessToken = json["access_token"] as? String,
           let scope = json["scope"] as? String,
           let tokenType = json["token_type"] as? String {
            Logger.shared.debug("Successfully parsed accessToken \(accessToken)")
            return TokenInfo(accessToken: accessToken, scope: scope, tokenType: tokenType)
        } else {
            Logger.shared.error("Failed to parse access token: \(String(data: data, encoding: .utf8) ?? "")")
            return nil
        }
    }
}
