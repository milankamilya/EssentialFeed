//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by MK on 13/11/21.
//

import XCTest
@testable import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesnotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestCacheRetrival() {
        let (sut, store) = makeSUT()

        sut.load() {_ in}
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrivalError() {
        let retrivalError = anyNSError()
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(retrivalError)) {
            store.completionRetrival(error: retrivalError)
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {

        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success([])) {
            store.completionWithEmptyCache()
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResults, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {

        let exp = expectation(description: "Waiting for retrieve completion")
        
        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedImages), .success(receivedImages)):
                XCTAssertEqual(expectedImages, receivedImages, file: file, line: line)
                
            case let (.failure(expectedError as NSError), .failure(receivedError as NSError)):
                XCTAssertEqual(expectedError.domain, receivedError.domain, file: file, line: line)
                XCTAssertEqual(expectedError.code, receivedError.code, file: file, line: line)
            
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    
}
