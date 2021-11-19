//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by MK on 19/11/21.
//

import XCTest
@testable import EssentialFeed
@testable import EssentialFeedTests

class EssentialFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemsOnEmptyImages() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Waiting for load completion")
        sut.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, [])
            case let .failure(error):
                XCTFail("Expected empty feed, but got \(error) instead.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        let expToSave = expectation(description: "Waiting for save completion")
        sutToPerformSave.save(feed: feed) { error in
            XCTAssertNil(error, "Expected to save feed successfully")
            expToSave.fulfill()
        }
        wait(for: [expToSave], timeout: 1.0)
        
        let expToLoad = expectation(description: "Waiting for load completion")
        sutToPerformLoad.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, feed)
                
            case let .failure(error):
                XCTFail("Expected empty feed, but got \(error) instead.")
            }
            expToLoad.fulfill()
        }
        wait(for: [expToLoad], timeout: 1.0)
        
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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
