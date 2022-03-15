//
//  FeedImageLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by MK on 15/03/22.
//

import XCTest
import EssentialFeed

protocol FeedImageDataCache {
    typealias SaveResult = Result<Void, Swift.Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            
            self?.cache.save( (try? result.get()) ?? Data("any".utf8), for: url) {_ in}
            completion(result)
        }
    }
}

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {

    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let (sut, loader) = makeSUT()
        let anyData = anyData()
        
        expect(sut, toCompleteWith: .success(anyData)) {
            loader.complete(with: anyData)
        }
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let (sut, loader) = makeSUT()
        let error = anyNSError()
        
        expect(sut, toCompleteWith: .failure(error)) {
            loader.complete(with: error)
        }
    }
    
    func test_loadImageData_cacheImageDataOnLoaderSuccess() {
        let cache = FeedImageDataCacheSpy()
        let (sut, loader) = makeSUT(with: cache)
        let url = anyURL()
        let data = anyData()
        
        let exp = expectation(description: "Waiting for loading")
        _ = sut.loadImageData(from: url) { result in
            exp.fulfill()
        }
        loader.complete(with: data)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(cache.messages, [.save(data, url)], "Expected to receive save message, but got \(cache.messages) instead.")
    }
    
    // MARK: - Helpers
    private func makeSUT( with cache: FeedImageDataCacheSpy = .init(), _ file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderCacheDecorator, loader: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, on action: () -> Void, _ file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Waiting for image loading")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, "Expected to receive \(expectedData)", file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected to receive \(expectedResult), but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private class FeedImageDataCacheSpy: FeedImageDataCache {
        var messages = [Message]()
        enum Message: Equatable {
            case save(Data, URL)
        }
        
        func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(data, url))
            completion(.success(()))
        }
    }
}
