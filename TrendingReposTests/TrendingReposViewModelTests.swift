import XCTest
@testable import TrendingRepos

class TrendingReposViewModelTests: XCTestCase {
    var sut: TrendingReposViewModel!
    var mockTokenManager: TokenManager!
    var mockAlertManager: AlertManager!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        mockTokenManager = TokenManager()
        mockAlertManager = AlertManager()
        mockNetworkManager = MockNetworkManager()
        sut = TrendingReposViewModel(tokenManager: mockTokenManager, alertManager: mockAlertManager, networkManager: mockNetworkManager)
    }
    
    override func tearDown() {
        sut = nil
        mockTokenManager = nil
        mockAlertManager = nil
        super.tearDown()
    }
    
    
    func testGetTrendingRepositoriesUpdatesRepos() {
        // Arrange
        let expectation = self.expectation(description: "expect repos to be populated after calling getTrendingRepositories")
        
        mockNetworkManager.stubResponse = [SearchResult(author: "zizifn", name: "edgetunnel", avatar: "https://github.com/zizifn.png", url: "https://github.com/zizifn/edgetunnel", description: "Running V2ray inside edge/serverless runtime", language: "JavaScript", languageColor: "#f1e05a", stars: 1837, forks: 12003, currentPeriodStars: 420)]
        
        // Act
        sut.getTrendingRepositories(timeFrame: "daily")
        
        // Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            XCTAssertFalse(self.sut.repos.isEmpty, "repos should not be empty")
            XCTAssertEqual(self.sut.repos.count, 1)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGetTrendingRepositoriesUpdatesIsLoading() {
        // Arrange
        let expectation = self.expectation(description: "expect isLoading to be handled properly after calling getTrendingRepositories")
        
        mockNetworkManager.stubResponse = [SearchResult(author: "zizifn", name: "edgetunnel", avatar: "https://github.com/zizifn.png", url: "https://github.com/zizifn/edgetunnel", description: "Running V2ray inside edge/serverless runtime", language: "JavaScript", languageColor: "#f1e05a", stars: 1837, forks: 12003, currentPeriodStars: 420)]
        
        // Act
        sut.getTrendingRepositories(timeFrame: "daily")
        
        // Assert
        XCTAssertTrue(sut.isLoading, "isLoading should be true immediately after fetch")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            XCTAssertFalse(self.sut.isLoading, "isLoading should be false after getting response")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testGetTrendingRepositoriesUpdatesIsError() {
        // Arrange
        let expectation = self.expectation(description: "expect isError to be handled properly after calling getTrendingRepositories")
        mockNetworkManager.shouldReturnError = true
        
        // Act
        sut.getTrendingRepositories(timeFrame: "daily")
        
        // Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            XCTAssertTrue(self.sut.isError, "isError should be true after getting error response")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
}

enum MockNetworkError: Error {
    case genericError
}

class MockNetworkManager: NetworkManager {
    var stubResponse: [SearchResult] = []
    var shouldReturnError = false
    
    override func fetchTrendingRepos(timeFrame: String = "daily", language: String? = nil, completion: @escaping (Result<[SearchResult], Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(MockNetworkError.genericError))
        } else {
            completion(.success(stubResponse))
        }
    }
}
