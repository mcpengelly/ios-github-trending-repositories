import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var tokenManager: TokenManager
    @EnvironmentObject var alertManager: AlertManager
    @State private var repos: [SearchResult] = []
    @State private var isLoading: Bool = false
    @State private var selectedTimeFrame: TimeFrame = .daily
    @State var isError = false
    
    var loggedIn: Bool {
        tokenManager.accessToken != nil
    }
    
    let loginStatuses = [
        true: "person.fill.checkmark",
        false: "person.fill.xmark"
    ]
    
    enum TimeFrame: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        
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
    
    var body: some View {
        // TODO: MVVM, THIS FILE IS WAY TOO COMPLICATED FOR A CONTENTVIEW
        TabView(selection: $selectedTimeFrame) {
            ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Trending Repositories: \(timeFrame.rawValue)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.bottom, 20)
                        }
                        
                        HStack {
                            Text("Login with Github:")
                            Image(systemName: loginStatuses[loggedIn] ?? "person.fill.xmark")
                                .foregroundColor(loggedIn ? Color.green : Color.red)
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)
                        
                        if !isLoading && !repos.isEmpty {
                            RepoList(repos: repos)
                        } else {
                            ProgressView()
                                .scaleEffect(4)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .padding()
                }
                .tabItem {
                    Text(timeFrame.rawValue)
                }
                .tag(timeFrame)
            }
        }
        .alert(isPresented: $alertManager.showAlert) {
            Alert(
                title: Text($alertManager.title.wrappedValue),
                message: Text($alertManager.description.wrappedValue),
                dismissButton: .default(Text("OK")
            ) {
                alertManager.resetAlert()
            })
        }
        .onAppear {
            getTrendingRepositories(timeFrame: selectedTimeFrame.rawValue.lowercased())
        }
        .onChange(of: selectedTimeFrame) { newValue in
            getTrendingRepositories(timeFrame: newValue.rawValue.lowercased())
        }
    }
    
    func getTrendingRepositories(timeFrame: String) {
        isLoading = true
        
        NetworkManager.shared.fetchTrendingRepos(timeFrame: timeFrame) { result in
            switch result {
            case .success(let fetchedRepos):
                DispatchQueue.main.async {
                    Logger.shared.debug("Data received: \(repos)")
                    repos = fetchedRepos
                }
            case .failure(let error):
                Logger.shared.error("\(error)")
                alertManager.handle(error: .noData)
//                isError = true
            }
            isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// easily create a Color from a hex value
extension Color {
    init?(hex: String) {
        let formattedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgbValue: UInt64 = 0
        
        guard Scanner(string: formattedHex).scanHexInt64(&rgbValue),
              formattedHex.count == 6 else {
            return nil
        }
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(UIColor(red: red, green: green, blue: blue, alpha: 1.0))
    }
}

// TODO: determine whether this is simply a wrapper class or a useful abstraction
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

