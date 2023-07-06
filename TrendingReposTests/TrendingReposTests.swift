//
//  TrendingReposTests.swift
//  TrendingReposTests
//
//  Created by Matt Pengelly on 2023-07-05.
//

import XCTest

// main things that need to remain functional for the app to be in a good state:
// starring/unstarring repo
// checking if a repo is already starred or not - isStarred/notStarred cases
// ensure we hit the correct endpoint for daily/weekly/monthly - just test that the url is formatted correctly in all 3 cases?
// github auth login - how do you reliably test this?

final class TrendingReposTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
