//
//  LocalFeedImageDataTests.swift
//  EssentialFeedTests
//
//  Created by MK on 02/02/22.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL: URL, completion: @escaping (Result) -> Void)
}

private class LocalFeedImageDataLoader {
    
    enum Error: Swift.Error {
        case failed
    }
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        store.retrieve(dataForURL: url) { result in
            completion(.failure(Error.failed))
        }

        return Task()
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_doesNotMessageStoreOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataForURL: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let clientError = NSError(domain: "client-error", code: 0)
        
        var receivedError: LocalFeedImageDataLoader.Error?
        let exp = expectation(description: "Waiting for loading")
        _ = sut.loadImageData(from: url, completion: { result in
            switch result {
            case let .failure(error as LocalFeedImageDataLoader.Error):
                receivedError = error

            default:
                XCTFail("Expected to receive failure with a client error, but receive \(result) instead.")
            }
            exp.fulfill()
        })
        
        store.complete(with: clientError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError, LocalFeedImageDataLoader.Error.failed)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private class FeedStoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataForURL: URL)
        }
        var receivedMessages = [Message]()
        var completions = [(FeedImageDataStore.Result) -> Void]()
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            completions.append(completion)
            receivedMessages.append(.retrieve(dataForURL: url))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
}
