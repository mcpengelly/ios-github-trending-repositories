import SwiftUI



//https://api.gitterapp.com/repositories?language=javascript&since=weekly

struct ContentView: View {
    
    
    @State private var repos: [Repo] = []
    
    // Add this before the `var body: some View` line
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

    // Add this inside the `ContentView` struct
    @State private var selectedTimeFrame: TimeFrame = .daily
    let MAX_LINES_DESCRIPTION = 4
    let SINGLE_LINE = 1

    var body: some View {
        TabView(selection: $selectedTimeFrame) {
            ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Trending Repositories")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 20)
                        

                        ForEach(repos.indices, id: \.self) { index in
                            let repo = repos[index]
                            VStack(alignment: .leading) {
                                if let url = URL(string: repo.html_url) {
                                    Link(destination: url) {
                                        VStack(alignment: .leading) {
                                            Text("\(repo.author)/\(repo.name)")
                                                .font(.headline)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .lineLimit(SINGLE_LINE)

                                            if let description = repo.description {
                                                Text(description)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                    .multilineTextAlignment(.leading)
                                                    .lineLimit(MAX_LINES_DESCRIPTION)
                                            }

                                            if let topics = repo.topics {
                                                let topThree = topics.prefix(3).joined(separator: ", ")
                                                Text(topThree)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                    .lineLimit(SINGLE_LINE)
                                            }
                                            HStack {
                                                Image(systemName: "star")
                                                Text(String(repo.stargazers_count))
                                                Divider()
                                                Image(systemName: "arrow.triangle.branch")
                                                Text(String(repo.forks_count))
                                                if let language = repo.language {
                                                    Divider()
                                                    Text(language)
                                                }
                                            }
                                            .padding(2)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .lineLimit(SINGLE_LINE)

                                        }.padding(10)
                                    }
                                } else {
                                    Text("\(repo.author)/\(repo.name)")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(SINGLE_LINE)

                                    Text("Invalid URL")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 2))
                        }
                    }
                    .padding()
                }
                .tabItem {
                    Text(timeFrame.rawValue)
                }
                .tag(timeFrame)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width > 50 { // Right swipe
                                selectedTimeFrame = selectedTimeFrame.previous()
                            } else if value.translation.width < -50 { // Left swipe
                                selectedTimeFrame = selectedTimeFrame.next()
                            }
                        }
                )
            }
        }
        .onAppear {
            NetworkManager.shared.fetchTrendingRepos(timeFrame: selectedTimeFrame.rawValue.lowercased()) { result in
                switch result {
                case .success(let fetchedRepos):
                    DispatchQueue.main.async {
                        repos = fetchedRepos
                    }
                case .failure(let error):
                    print("Error fetching repos: \(error)")
                }
            }
        }
        .onChange(of: selectedTimeFrame) { newValue in
            NetworkManager.shared.fetchTrendingRepos(timeFrame: newValue.rawValue.lowercased()) { result in
                switch result {
                case .success(let fetchedRepos):
                    DispatchQueue.main.async {
                        repos = fetchedRepos
                    }
                case .failure(let error):
                    print("Error fetching repos: \(error)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
