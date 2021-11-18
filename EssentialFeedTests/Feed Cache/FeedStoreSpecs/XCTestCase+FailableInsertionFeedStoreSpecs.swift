//
//  XCTestCase+FailableInsertionFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by MK on 17/11/21.
//

import Foundation
import XCTest
import EssentialFeed

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversErrorOnInvalidCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .failure(error: anyNSError()), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectOnInvalidCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {        
        expect(sut, toRetrieveTwice: .failure(error: anyNSError()), file: file, line: line)
    }
}
