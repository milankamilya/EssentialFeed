//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by MK on 12/11/21.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    let store: FeedStore
    let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self](error) in
            if error == nil {
                store.insert(items: items, timestamp: currentDate())
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void

    enum ReceivedMessages: Equatable {
        case deleteCachedFeed
        case insert([FeedItem], Date)
    }
    
    var receivedMessages = [ReceivedMessages]()
    
    private var deletionCompletions = [DeletionCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion ) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func insert(items: [FeedItem], timestamp: Date) {
        receivedMessages.append(.insert(items, timestamp))
    }
    
    func completionDeletion(error: NSError, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completionDeletionSuccesfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesnotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items: items)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
       
    func test_save_doesntRequestCacheInsertionOnDeletionFailed() {
        let items = [uniqueItem(), uniqueItem()]
        let error = anyNSError()
        let (sut, store) = makeSUT()
        
        sut.save(items: items)
        store.completionDeletion(error: error)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(items: items)
        store.completionDeletionSuccesfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
    }
       
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
}
