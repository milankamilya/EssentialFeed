//
//  LocalFeedImageDataTests.swift
//  EssentialFeedTests
//
//  Created by MK on 02/02/22.
//

import XCTest
import EssentialFeed

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
        
        expect(sut, expecting: failed()) {
            let clientError = anyNSError()
            store.completeRetrieval(with: clientError)
        }
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, expecting: notFound()) {
            store.completeRetrieval(with: .none)
        }
    }
    
    func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let anyData = anyData()
        
        expect(sut, expecting: .success(anyData)) {
            store.completeRetrieval(with: anyData)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliversResultAfterCancellationOfTask() {
        let (sut, store) = makeSUT()
        
        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        
        task.cancel()
        
        store.completeRetrieval(with: anyData())
        store.completeRetrieval(with: nil)
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertTrue(received.isEmpty, "Expected any empty results for a cancelled task")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var received = [FeedImageDataLoader.Result]()
        _  = sut?.loadImageData(from: anyURL(), completion: { received.append($0) })
        
        sut = nil
        
        store.completeRetrieval(with: anyData())
        
        XCTAssertTrue(received.isEmpty, "Expected no results for a deallocated instance")
    }
    
    func test_saveIamgeDataForURL_requestImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()
        
        sut.save(data, for: url) {_ in}
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, url: url)])
    }
    
    // MARK: - Helpers
    
    private func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, expecting expectedResult: FeedImageDataLoader.Result, on action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for loading")

        _ = sut.loadImageData(from: anyURL(), completion: { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as LocalFeedImageDataLoader.LoadError), .failure(expectedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        })
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class FeedStoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataForURL: URL)
            case insert(data: Data, url: URL)
        }
        var receivedMessages = [Message]()
        var retrievalCompletions = [(FeedImageDataStore.RetrieveResult) -> Void]()
        
        func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
            receivedMessages.append(.insert(data: data, url: url))
        }
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult) -> Void) {
            retrievalCompletions.append(completion)
            receivedMessages.append(.retrieve(dataForURL: url))
        }
        
        func completeRetrieval(with error: Error, at index: Int = 0) {
            retrievalCompletions[index](.failure(error))
        }
        
        func completeRetrieval(with data: Data?, at index: Int = 0) {
            retrievalCompletions[index](.success(data))
        }
    }
}
