//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by MK on 17/11/21.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectOnEmptyCache()
    func test_retrieve_deliversFoundValueOnNonEmptyCache()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache()
    
    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridePreviouslyInsertedValues()
    
    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_hasNoEffectOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_leavesEmptyCacheOnNonEmptyCache()
    
    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversErrorOnInvalidCache()
    func test_retrieve_hasNoSideEffectsOnInvalidCache()
}

protocol FailableInsertionFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeletionFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliverErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStore = FailableRetrieveFeedStoreSpecs & FailableInsertionFeedStoreSpecs & FailableDeletionFeedStoreSpecs
