//
//  RemoteLoaderWithLocalFallbackTests.swift
//  EssentialAppTests
//
//  Created by MK on 25/02/22.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))

        expect(sut, toCompleteWith: .success(primaryFeed))
    }
    
    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(fallbackFeed))
    }
    
    func test_load_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
        let primaryError = anyNSError()
        let fallbackError = anyNSError()
        let sut = makeSUT(primaryResult: .failure(primaryError), fallbackResult: .failure(fallbackError))
        
        expect(sut, toCompleteWith: .failure(fallbackError))
    }
    
    // MARK: - Helpers
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, _ file: StaticString = #file, line: UInt = #line) -> FeedLoaderWithFallback {
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallback(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: FeedLoaderWithFallback, toCompleteWith expectedResult: FeedLoader.Result, _ file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError  as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "https://any-url.com")!)]
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    
    class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
