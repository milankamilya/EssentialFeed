//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by MK on 14/11/21.
//

import Foundation

import XCTest
@testable import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesnotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrivalError() {
        let retrivalError = anyNSError()
        let (sut, store) = makeSUT()
        
        sut.validateCache() {_ in}
        store.completionRetrival(error: retrivalError)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache() {_ in}
        store.completionWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeletNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date.init()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT { return fixedCurrentDate }
        
        sut.validateCache() {_ in}
        store.completionRetrival(with: feed.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deleteCacheOnCacheExpirationDate() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date.init()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT { return fixedCurrentDate }
        
        sut.validateCache() {_ in}
        store.completionRetrival(with: feed.local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_deleteCacheOnExpiredDate() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date.init()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT { return fixedCurrentDate }
        
        sut.validateCache() {_ in}
        store.completionRetrival(with: feed.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completionRetrival(error: anyNSError())
            store.completionDeletion(error: deletionError)
        })
    }
    
    func test_validateCache_doesNotDeleteCacheAfterSUTInstanceHasBeenDeallocated() {
        let retrivalError = anyNSError()
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache() {_ in}
        sut = nil
        store.completionRetrival(error: retrivalError)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.ValidationResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line ) {
        let exp = expectation(description: "Waiting for validation")
        
        sut.validateCache { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
            
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected to receive \(expectedResult), but got \(receivedResult).", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
