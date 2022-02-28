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
        let sut = makeSUT(primaryResult: .success(primaryData), fallbackResult: .success(fallbackData))
        
        expect(sut, toCompleteWith: .success(primaryData))
    }
    
    func test_loadImageData_deliversFallbackSuccessOnPrimaryLoaderFailure() {
        let fallbackData = anyData()
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackData))
        
        expect(sut, toCompleteWith: .success(fallbackData))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(primaryResult: FeedImageDataLoader.Result, fallbackResult: FeedImageDataLoader.Result, _ file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoaderWithFallbackComposite {
        let primaryLoader = FeedImageDataLoaderStub(result: primaryResult)
        let fallbackLoader = FeedImageDataLoaderStub(result: fallbackResult)
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: FeedImageDataLoaderWithFallbackComposite, toCompleteWith expectedResult: FeedImageDataLoader.Result, _ file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
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

