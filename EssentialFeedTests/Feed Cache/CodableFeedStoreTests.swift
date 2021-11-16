//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by MK on 16/11/21.
//

import XCTest
@testable import EssentialFeed

class CodableFeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrivalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let cache = try! JSONDecoder().decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }

    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Waiting for completion")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expecting a empty result, got \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func test_retrieve_hasNoSideOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Waiting for completion")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retriving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead.")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        
        let insertedFeed = uniqueImageFeed().local
        let insertedTimestamp = Date()
        let sut = makeSUT()
        
        let exp = expectation(description: "Waiting for completion")
        
        sut.insert(feed: insertedFeed, timestamp: insertedTimestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            
            sut.retrieve { retrivedResult in
                switch (retrivedResult) {
                case let .found(retrieveFeed, retrieveTimestamp):
                    XCTAssertEqual(insertedFeed, retrieveFeed)
                    XCTAssertEqual(insertedTimestamp, retrieveTimestamp)
                    break
                default:
                    XCTFail("Expecting retrieval of inserted \(insertedFeed) and \(insertedTimestamp), got \(retrivedResult) instead.")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
        let insertedFeed = uniqueImageFeed().local
        let insertedTimestamp = Date()
        let sut = makeSUT()
        
        let exp = expectation(description: "Waiting for completion")
        
        sut.insert(feed: insertedFeed, timestamp: insertedTimestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            sut.retrieve { firstResult in
                sut.retrieve { secondResult in
                    switch (firstResult, secondResult) {
                    case let (.found(firstFound), .found(secondFound)):
                        XCTAssertEqual(firstFound.feed, insertedFeed)
                        XCTAssertEqual(firstFound.timestamp, insertedTimestamp)
                        
                        XCTAssertEqual(secondFound.feed, insertedFeed)
                        XCTAssertEqual(secondFound.timestamp, insertedTimestamp)
                        break
                    default:
                        XCTFail("Expecting retrieval twice from non-empty cache to deliver same found result with feed \(insertedFeed) and \(insertedTimestamp) twice, got \(firstResult) and \(secondResult) instead..")
                    }
                    exp.fulfill()
                }
            }
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> CodableFeedStore {
        let store = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(store)
        return store
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
