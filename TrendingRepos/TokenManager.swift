//
//  TokenManager.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-06-24.
//
import Foundation

struct TokenData: Decodable {
    var accessToken: String
    var scope: String
    var tokenType: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case scope
        case tokenType = "token_type"
    }
}

class TokenManager: ObservableObject {
    @Published var accessToken: String? // Published ensures the UI updates occur for those relying on this
    
    func setAccessToken(_ token: String, shouldPersist: Bool = true) {
        DispatchQueue.main.async { [self] in
            // Persists to keychain if requested (also updates the ui), if not itll just update the UI
            if shouldPersist {
                // Save token to ios keychain
                if KeychainHelper.set("githubAccessToken", value: token) {
                    self.accessToken = token
                } else {
                    Logger.shared.error("Something went wrong when setting the Access Token on IOS Keychain")
                }
            } else {
                self.accessToken = token
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
            if KeychainHelper.delete("githubAccessToken") {
                Logger.shared.debug("Successfully deleted githubAccessToken from IOS Keychain")
            } else {
                Logger.shared.debug("Unable to clear githubAccessToken from IOS Keychain")
            }
        }
    }
    
    func requestAccessToken(authCode: String, completion: @escaping (TokenData?) -> Void) {
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
                } else {
                    // TODO: use completion handler .failure instead)
                    Logger.shared.error("access token could not be parsed from data: \(data)")
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func parseAccessToken(from data: Data) -> TokenData? {
        let decoder = JSONDecoder()
        do {
            let tokenData = try decoder.decode(TokenData.self, from: data)
            Logger.shared.debug("Successfully parsed accessToken \(tokenData)")
            return tokenData
        } catch {
            Logger.shared.error("Failed to parse access token: \(String(data: data, encoding: .utf8) ?? "")")
            return nil
        }
    }
}
