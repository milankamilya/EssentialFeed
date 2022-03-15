//
//  FeedImageLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by MK on 15/03/22.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {

    func test_loadImageData_doesNotLoadOnInit() {
        let (_, loader) = makeSUT()
            
        XCTAssertTrue(loader.messages.isEmpty, "Expected not to receive any load request on init")
    }
    
    func test_loadImageData_loadsFromLoader() {
        let (sut, loader) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) {_ in}
        
        XCTAssertEqual(loader.loadedURLs, [url], "Expected to load URL from loader.")
    }
    
    func test_cancelLoadImageData_cancelsLoaderTask() {
        let (sut, loader) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) {_ in}
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLS, [url], "Expected to cancel URL loading from loader.")
    }
    
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
        
        _ = sut.loadImageData(from: url) {_ in}
        loader.complete(with: data)
        
        XCTAssertEqual(cache.messages, [.save(data, url)], "Expected to receive save message, but got \(cache.messages) instead.")
    }
    
    func test_loadImageData_doesNotCacheImageDataOnLoaderFailure() {
        let cache = FeedImageDataCacheSpy()
        let (sut, loader) = makeSUT(with: cache)
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) {_ in}
        loader.complete(with: anyNSError())
        
        XCTAssertTrue(cache.messages.isEmpty, "Expected not to save cache, but got \(cache.messages) instead.")
    }
    
    func test_loadImageData_doesNotCacheOnLoaderTaskCancelled() {
        let cache = FeedImageDataCacheSpy()
        let (sut, _) = makeSUT(with: cache)
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) {_ in}
        task.cancel()
        
        XCTAssertTrue(cache.messages.isEmpty, "Expected not to save cache, but got \(cache.messages) instead.")
    }
    
    // MARK: - Helpers
    private func makeSUT( with cache: FeedImageDataCacheSpy = .init(), _ file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderCacheDecorator, loader: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private class FeedImageDataCacheSpy: FeedImageDataCache {
        var messages = [Message]()
        enum Message: Equatable {
            case save(Data, URL)
        }
        
        func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
            messages.append(.save(data, url))
            completion(.success(()))
        }
    }
}
