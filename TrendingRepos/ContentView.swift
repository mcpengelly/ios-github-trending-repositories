import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var tokenManager: TokenManager
    @EnvironmentObject var alertManager: AlertManager
    @ObservedObject var viewModel: TrendingReposViewModel
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
    
    var body: some View {
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
                            if loggedIn {
                                Spacer()
                                Button("Logout") {
                                    tokenManager.clearAccessToken()
                                }
                                .frame(width: 55, height: 10)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                                .font(.subheadline)
                            }
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
                                .padding(100)
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
                dismissButton: .default(
                   Text("OK")) {
                       alertManager.resetAlert()
                   }
            )
        }
        .onAppear {
            if let token = tokenManager.getAccessToken() {
                tokenManager.setAccessToken(token, shouldPersist: false)
            }
            
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
            }
            isLoading = false
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // TODO: replace with actual mocks?
        let mockTokenManager = TokenManager()
        let mockAlertManager = AlertManager()
        let mockViewModel = TrendingReposViewModel(tokenManager: mockTokenManager, alertManager: mockAlertManager)
        
        ContentView(viewModel: mockViewModel)
            .environmentObject(mockTokenManager)
            .environmentObject(mockAlertManager)
    }
}
