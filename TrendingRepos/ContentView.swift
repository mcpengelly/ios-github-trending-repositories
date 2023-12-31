import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var tokenManager: TokenManager
    @EnvironmentObject var alertManager: AlertManager
    @ObservedObject var viewModel: TrendingReposViewModel
    @ObservedObject var darkModeManager: DarkModeManager
    
    @State private var selectedTimeFrame: TimeFrame = .daily
    
    var loggedIn: Bool {
        tokenManager.accessToken != nil
    }
    
    let loginStatuses = [
        true: "person.fill.checkmark",
        false: "person.fill.xmark"
    ]
    
    
    var body: some View {
        let toggleDarkMode = Button(action: {
            darkModeManager.toggleDarkMode()
            UIAccessibility.post(
                notification: .announcement,
                argument: NSLocalizedString("toggled_dark_mode", comment: "After dark mode toggle announcement")
            )
        }, label: {
            Image(systemName: darkModeManager.darkModeEnabled ? "sun.max.fill" : "moon.fill")
                .foregroundColor(.gray)
        }).accessibilityLabel(NSLocalizedString("toggle_dark_mode", comment: "Dark mode Button"))
        
        TabView(selection: $selectedTimeFrame) {
            ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                ScrollView {
                    VStack(alignment: .leading) {
                        let pageTitle = NSLocalizedString("title_timeframe", comment: "title with timeframe argument")
                        let localizedPageTitle = String(format: pageTitle, NSLocalizedString(timeFrame.rawValue, comment: "time frame"))
                        
                        HStack {
                            toggleDarkMode
                            Text(NSLocalizedString("login_with_github", comment: "github oauth button"))
                            Image(systemName: loginStatuses[loggedIn] ?? "person.fill.xmark")
                                .foregroundColor(loggedIn ? Color.green : Color.red)
                            if loggedIn {
                                Spacer()
                                Button(NSLocalizedString("logout", comment: "oauth logout")) {
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
                        .foregroundColor(darkModeManager.darkModeEnabled ? .white : .black)
                        
                        HStack {
                            Text(localizedPageTitle)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.bottom, 20)
                                .foregroundColor(darkModeManager.darkModeEnabled ? .white : .black)
                        }
                        
                        if !viewModel.isLoading && !viewModel.repos.isEmpty {
                            RepoList(repos: viewModel.repos)
                        } else {
                            ProgressView()
                                .scaleEffect(4)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .progressViewStyle(
                                    CircularProgressViewStyle(tint: darkModeManager.darkModeEnabled ?  Color.white : Color.black)
                                )
                                .padding(100)
                        }
                    }
                    .padding()
                }
                .background(darkModeManager.darkModeEnabled ? .black : .white)
                .tabItem {
                    Text(NSLocalizedString(timeFrame.rawValue, comment: "Tabs"))
                }
                .tag(timeFrame)
            }
        }
        .alert(isPresented: $alertManager.showAlert) {
            Alert(
                title: Text($alertManager.title.wrappedValue),
                message: Text($alertManager.description.wrappedValue),
                dismissButton: .default(
                   Text(NSLocalizedString("ok", comment: "ok button"))) {
                       alertManager.resetAlert()
                   }
            )
        }
        .onAppear {
            if let token = tokenManager.getAccessToken() {
                tokenManager.setAccessToken(token, shouldPersist: false)
            }
            
            viewModel.getTrendingRepositories(timeFrame: selectedTimeFrame.rawValue.lowercased())
        }
        .onChange(of: selectedTimeFrame) { newValue in
            viewModel.getTrendingRepositories(timeFrame: newValue.rawValue.lowercased())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        @ObservedObject var darkModeManager = DarkModeManager()
        
        // TODO: replace with actual mocks?
        let mockTokenManager = TokenManager()
        let mockAlertManager = AlertManager()
        let mockViewModel = TrendingReposViewModel(tokenManager: mockTokenManager, alertManager: mockAlertManager)
        
        ContentView(viewModel: mockViewModel, darkModeManager: darkModeManager)
            .environmentObject(mockTokenManager)
            .environmentObject(mockAlertManager)
    }
}
