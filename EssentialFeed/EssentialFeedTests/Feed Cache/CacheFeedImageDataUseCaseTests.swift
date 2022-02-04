//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by MK on 04/02/22.
//

import XCTest
import EssentialFeed

class CacheFeedImageDataUseCaseTests: XCTestCase {
    
    func test_doesNotMessageStoreOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_saveIamgeDataForURL_requestImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()
        
        sut.save(data, for: url) {_ in}
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, url: url)])
    }
    
    func test_saveImageDataForURL_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()
        
        expect(sut, expecting: .failure(LocalFeedImageDataLoader.SaveError.failed)) {
            store.completeInsertion(with: anyNSError())
        }
    }
    
    func test_saveImageDataForURL_succeedsOnSuccessfulStoreInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, expecting: .success(())) {
            store.completeInsertionSuccessfully()
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, expecting expectedResult: LocalFeedImageDataLoader.SaveResult, on action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for saving")
        
        sut.save(anyData(), for: anyURL()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success, .success):
                break

            case let (.failure(expectedError as LocalFeedImageDataLoader.SaveError), .failure(receivedError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
}
