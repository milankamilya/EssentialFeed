//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by MK on 13/11/21.
//

import Foundation

public typealias CacheResult = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    
    typealias DeletionResult = Error?
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Error?
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrievalResult = Result<CacheResult?, Error>
    typealias RetrivalCompletion = (FeedStore.RetrievalResult) -> Void
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropriate thread, if needed
    func deleteCachedFeed(completion: @escaping DeletionCompletion )
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropriate thread, if needed
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropriate thread, if needed
    func retrieve(completion: @escaping RetrivalCompletion)
}

