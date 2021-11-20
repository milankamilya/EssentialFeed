//
//  XCTestCase+FailableDeletionFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by MK on 18/11/21.
//

import Foundation
import XCTest
@testable import EssentialFeed

extension FailableDeletionFeedStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliverErrorOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.empty), file: file, line: line)
    }
}
