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
}
