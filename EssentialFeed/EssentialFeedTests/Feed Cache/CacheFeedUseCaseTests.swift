//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by MK on 12/11/21.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesnotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save(feed: uniqueImageFeed().models) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
       
    func test_save_doesntRequestCacheInsertionOnDeletionFailed() {
        let deletionError = anyNSError()
        let (sut, store) = makeSUT()
        
        sut.save(feed: uniqueImageFeed().models) { _ in }
        store.completionDeletion(error: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = uniqueImageFeed()

        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(feed: items.models) { _ in }
        store.completionDeletionSuccesfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items.local, timestamp)])
    }
       
    func test_save_failsOnDeletionError() {
        let timestamp = Date()
        let deletionError = anyNSError()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        expect(sut: sut, toCompletionWithError: deletionError) {
            store.completionDeletion(error: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let timestamp = Date()
        let insertionError = anyNSError()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        expect(sut: sut, toCompletionWithError: insertionError) {
            store.completionDeletionSuccesfully()
            store.completionInsertion(error: insertionError)
        }
    }

    func test_save_succeedOnSuccessfulCacheInsertion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        expect(sut: sut, toCompletionWithError: nil) {
            store.completionDeletionSuccesfully()
            store.completionInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let deletionError = anyNSError()
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResult = [LocalFeedLoader.SavedResults]()
        sut?.save(feed: uniqueImageFeed().models) { receivedResult.append($0) }

        sut = nil
        store.completionDeletion(error: deletionError)
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let deletionError = anyNSError()
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResult = [LocalFeedLoader.SavedResults]()
        sut?.save(feed: uniqueImageFeed().models) { receivedResult.append($0) }

        store.completionDeletionSuccesfully()
        sut = nil
        store.completionInsertion(error: deletionError)
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    func expect(sut: LocalFeedLoader, toCompletionWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for save completion")
        var capturedError: Error?
        
        sut.save(feed:  [uniqueImage(), uniqueImage()]) { result in
            if case let Result.failure(error) = result {
                capturedError = error
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(capturedError as NSError?, expectedError, file: file, line: line)
    }
}
