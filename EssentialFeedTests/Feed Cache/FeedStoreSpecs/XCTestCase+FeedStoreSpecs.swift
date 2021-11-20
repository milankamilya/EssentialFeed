//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by MK on 17/11/21.
//

import Foundation
import XCTest
@testable import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundValueOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert(cache: (feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .success(CacheResult(feed, timestamp)), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert(cache: (feed, timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .success(CacheResult(feed, timestamp)), file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let latestInsertionError = insert(cache: (uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(latestInsertionError, "Expected to insert cache successfully", file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(cache: (uniqueImageFeed().local, Date()), to: sut)

        let insertionError = insert(cache: (uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }
    
    func assertThatInsertOverridePreviouslyInsertedValues(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(cache: (uniqueImageFeed().local, Date()), to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        insert(cache: (latestFeed, latestTimestamp), to: sut)
        
        expect(sut, toRetrieve: .success(CacheResult(latestFeed, latestTimestamp)), file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected deletion not to return any error", file: file, line: line)
    }
    
    func assertThatDeleteHasNoEffectOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(cache: (uniqueImageFeed().local, Date()), to: sut)
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected to delete cache successfully", file: file, line: line)
    }
    
    func assertThatDeleteLeavesEmptyCacheOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        insert(cache: (uniqueImageFeed().local, Date()), to: sut)
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func assertThatStoreSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        var completedOperationInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(feed: uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(feed: uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationInOrder, [op1, op2, op3], "Expected side effects to finished in serially, but operations finishes in wrong order", file: file, line: line)
    }
    
}


extension FeedStoreSpecs where Self: XCTestCase {
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for cache retrival")

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.success(.none), .success(.none)),
                (.failure, .failure):
                break
                
            case let (.success(.some(expectedCache)), .success(.some(retrievedCache))):
                XCTAssertEqual(expectedCache.feed, retrievedCache.feed, file: file, line: line)
                XCTAssertEqual(expectedCache.timestamp, retrievedCache.timestamp, file: file, line: line)
                break
                
            default:
                XCTFail("Expecting retrieval of result \(expectedResult), got \(retrievedResult) instead.", file: file, line: line)
            }

            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    @discardableResult
    func insert(cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Waiting for completion")
        var insertionError: Error?
        sut.insert(feed: cache.feed, timestamp: cache.timestamp) { insertionResult in
            
            switch insertionResult {
            case .success: break
                
            case let .failure(error):
                insertionError = error
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Waiting for deletion to complete")
        var deletionError: Error?
        sut.deleteCachedFeed { deletionResult in
            
            switch deletionResult {
            case .success: break
                
            case let .failure(error):
                deletionError = error
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return deletionError
    }
}
