//
//  XCTestCase+FailableInsertionFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by MK on 18/11/21.
//

import Foundation
import XCTest
import EssentialFeed

extension FailableInsertionFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let insertionError = insert(cache: (uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected insertion to fail for invalid store url", file: file, line: line)
    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(cache: (uniqueImageFeed().local, Date()), to: sut)
        
        expect(sut, toRetrieve: .success(.empty), file: file, line: line)
    }
}
