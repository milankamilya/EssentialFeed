//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by MK on 14/03/22.
//

import XCTest
import EssentialFeed

protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(feed: [FeedImage], completion: @escaping (Result) -> Void)
}

final class FeedLoaderCacheDecorator: FeedLoader {
    let decoratee: FeedLoader
    let cache: FeedCache
    
    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.cache.save(feed: (try? result.get()) ?? []) {_ in}
            completion(result)
        }
    }
}

class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(loaderResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let cache = FeedCacheSpy()
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)

        sut.load {_ in}
        
        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache loaded feed on success")
    }
    
    // MARK: - Helpers
    private func makeSUT(loaderResult: FeedLoader.Result, cache: FeedCacheSpy = .init(), _ file: StaticString = #file, _ line: UInt = #line) -> (FeedLoaderCacheDecorator) {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private class FeedCacheSpy: FeedCache {
        var messages = [Message]()
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        func save(feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }

}
