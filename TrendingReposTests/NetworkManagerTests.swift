import XCTest
@testable import TrendingRepos

class NetworkManagerTests: XCTestCase {
    
    var sut: NetworkManager!
    var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        NetworkManager.shared.setSharedSession(mockSession)
        sut = NetworkManager.shared
    }
    
    override func tearDown() {
        NetworkManager.shared.setSharedSession(URLSession.shared)
        sut = nil
        mockSession = nil
        super.tearDown()
    }
    
    func testFetchTrendingReposHandlesSuccessPath() {
        // Arrange
        let expectation = self.expectation(description: "expect fetching trending repos should return a valid data format")
        var fetchResult: [SearchResult]?
        
        // Create a SearchResult object and encode it into Data
        let searchResult = SearchResult(author: "TestAuthor", name: "TestName", avatar: "TestAvatar", url: "TestUrl", description: "TestDescription", language: "TestLanguage", languageColor: "TestColor", stars: 1, forks: 1, currentPeriodStars: 1)
        let searchResults = [searchResult]
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(searchResults)
        
        // Set the jsonData as the data to be returned by the mockSession
        mockSession.data = jsonData

        // Act
        sut.fetchTrendingRepos(timeFrame: "daily") { result in
            switch result {
            case .success(let results):
                fetchResult = results
            case .failure(_):
                break
            }
            
            expectation.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(fetchResult)
        XCTAssertEqual(fetchResult?.first?.author, "TestAuthor")
    }

    func testFetchTrendingReposHandlesFailure() {
        // Arrange
        let expectation = self.expectation(description: "expect fetching trending repos should handle failure")
        var fetchError: Error?
        let expectedError = NSError(domain: "test", code: 123, userInfo: nil)
        mockSession.error = expectedError

        // Act
        sut.fetchTrendingRepos(timeFrame: "daily") { result in
            switch result {
            case .failure(let error):
                fetchError = error
            case _:
                break
            }
            
            expectation.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(fetchError)
        XCTAssertEqual(fetchError as NSError?, expectedError)
    }
    
    func testRequestFormation() {
        // Arrange
        let timeFrame = "daily"
        let expectedURL = URL(string: "https://api.gitterapp.com/repositories?&since=\(timeFrame)")

        // Act
        sut.fetchTrendingRepos(timeFrame: timeFrame) { _ in }

        // Assert
        XCTAssertEqual(mockSession.lastURL, expectedURL, "URL was not formed correctly")
    }

    func testHTTPMethod() {
        // Arrange
        let timeFrame = "daily"
        let expectedHTTPMethod = "GET"

        // Act
        sut.fetchTrendingRepos(timeFrame: timeFrame) { _ in }

        // Assert
        XCTAssertEqual(mockSession.lastHTTPMethod, expectedHTTPMethod, "HTTP method was not set correctly")
    }
}

class MockURLSession: URLSession {
    var data: Data?
    var error: Error?
    var lastURL: URL?
    var lastHTTPMethod: String?

    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        lastURL = request.url
        lastHTTPMethod = request.httpMethod
        let data = self.data
        let error = self.error
        return MockURLSessionDataTask {
            completionHandler(data, nil, error)
        }
    }
}


class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }
}
