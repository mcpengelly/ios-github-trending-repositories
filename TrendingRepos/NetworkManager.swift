import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let urlSession = URLSession.shared
    
    private init() {}
    
    func fetchTrendingRepos(timeFrame: String = "daily", completion: @escaping (Result<[SearchResult], Error>) -> Void) {
        let urlString = "https://api.gitterapp.com/repositories?&since=\(timeFrame)"
        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURLString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let searchResult: [SearchResult] = try decoder.decode([SearchResult].self, from: data)
                completion(.success(searchResult))
            } catch {
                completion(.failure(error))
            }
        }.resume()
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
    let builtBy: [Contributor]
}

struct Contributor: Codable {
    let username: String
    let href: String
    let avatar: String
}
