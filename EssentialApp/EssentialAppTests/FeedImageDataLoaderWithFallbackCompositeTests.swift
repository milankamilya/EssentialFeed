//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by MK on 28/02/22.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapper: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapper?.cancel()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let taskWrapper = TaskWrapper()
        _ = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)

            case .failure:
                _ = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        return taskWrapper
    }
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    func test_loadImageData_deliversSuccessOnPrimaryLoaderSuccess() {
        let primaryData = anyData()
        let fallbackData = anyData()
        let primaryLoader = FeedImageDataLoaderStub(result: .success(primaryData))
        let fallbackLoader = FeedImageDataLoaderStub(result: .success(fallbackData))
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        let exp = expectation(description: "Waiting for load completion")
        _ = sut.loadImageData(from: anyURL()) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, primaryData)

            case let .failure(error):
                XCTFail("Expected to receive \(primaryData), but got \(error) instead.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadImageData_deliversFallbackSuccessOnPrimaryLoaderFailure() {
        let fallbackData = anyData()
        let primaryLoader = FeedImageDataLoaderStub(result: .failure(anyNSError()))
        let fallbackLoader = FeedImageDataLoaderStub(result: .success(fallbackData))
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        let exp = expectation(description: "Waiting for load completion")
        _ = sut.loadImageData(from: anyURL()) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, fallbackData)

            case let .failure(error):
                XCTFail("Expected to receive \(fallbackData), but got \(error) instead.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    
    class FeedImageDataLoaderTaskStub: FeedImageDataLoaderTask {
        func cancel() { }
    }
    
    class FeedImageDataLoaderStub: FeedImageDataLoader {
        private let result: FeedImageDataLoader.Result
        
        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            completion(result)
            return FeedImageDataLoaderTaskStub()
        }
    }
    
}

