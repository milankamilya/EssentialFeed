//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by MK on 16/11/21.
//

import XCTest
@testable import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrivalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
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
        let sut = CodableFeedStore()
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
}
