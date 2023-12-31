import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private var urlSession: URLSession
    
    init() {
        self.urlSession = URLSession.shared
    }

    func fetchTrendingRepos(
        timeFrame: String = "daily",
        language: String? = nil, // TODO: language https://api.gitterapp.com/languages
        completion: @escaping (Result<[SearchResult], Error>
    ) -> Void) {
        var urlString = ""
        if let languageFilter = language {
            urlString = "https://api.gitterapp.com/repositories?&language=\(languageFilter)&since=\(timeFrame)"
        } else {
            urlString = "https://api.gitterapp.com/repositories?&since=\(timeFrame)"
        }
        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURLString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        self.urlSession.dataTask(with: request) { data, _, error in
            if let error = error {
                Logger.shared.error("error occurred while fetching repos: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                Logger.shared.debug("Failed to fetch trending repos")
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let searchResult: [SearchResult] = try decoder.decode([SearchResult].self, from: data)
                Logger.shared.debug("Fetched trending repos: \(searchResult)")
                completion(.success(searchResult))
            } catch {
                Logger.shared.error("error occurred while fetching repos: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Test helpers for singleton pattern
    func setSharedSession(_ session: URLSession) {
        self.urlSession = session
    }
}

// TODO: id issue?
struct SearchResult: Codable, Identifiable {
    let id = UUID()
    let author: String
    let name: String
    let avatar: String
    var url: String
    let description: String
    let language: String?
    let languageColor: String?
    let stars: Int
    let forks: Int
    let currentPeriodStars: Int
}

struct Contributor: Codable {
    let username: String
    let href: String
    let avatar: String
}
