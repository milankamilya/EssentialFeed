//
//  RemoteLoaderWithLocalFallbackTests.swift
//  EssentialAppTests
//
//  Created by MK on 25/02/22.
//

import XCTest
import EssentialFeed

class FeedLoaderWithFallback: FeedLoader {
    private let primary: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let primaryLoader = LoaderStub(result: .success(primaryFeed))
        let fallbackLoader = LoaderStub(result: .success(fallbackFeed))
        let sut = FeedLoaderWithFallback(primary: primaryLoader, fallback: fallbackLoader)

        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch receivedResult {
            case let .success(receivedFeed):
                XCTAssertEqual(primaryFeed, receivedFeed)

            case let .failure(error):
                XCTFail("Expected successful load feed result, got \(error) instead.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "https://any-url.com")!)]
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
