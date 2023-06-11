import Foundation

class NetworkManager {
    static let shared = NetworkManager()

    private init() {}

    func fetchTrendingRepos(timeFrame: String = "daily", completion: @escaping (Result<[Repo], Error>) -> Void) {
        let date: Date = {
            let calendar = Calendar.current
            switch timeFrame {
            case "weekly":
                return calendar.date(byAdding: .weekOfYear, value: -1, to: Date())!
            case "monthly":
                return calendar.date(byAdding: .month, value: -1, to: Date())!
            default:
                return calendar.date(byAdding: .day, value: -1, to: Date())!
            }
        }()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        let query = "created:>\(dateString)"
        let urlString = "https://api.github.com/search/repositories?q=\(query)&sort=stars&order=desc&per_page=15"
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
                let searchResult = try decoder.decode(SearchResult.self, from: data)
                completion(.success(searchResult.items ?? [])) /// should handle optional better
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct SearchResult: Codable {
    let items: [Repo]?
}

struct Repo: Codable, Identifiable {
    let id: Int
    let name: String
    let full_name: String
    let html_url: String
    let description: String?
    let stargazers_count: Int
    let language: String?
    let topics: [String]?
    let forks_count: Int

    var author: String {
        return full_name.components(separatedBy: "/").first ?? ""
    }
}
