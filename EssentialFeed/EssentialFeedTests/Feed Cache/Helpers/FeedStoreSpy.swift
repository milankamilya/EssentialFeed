//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by MK on 13/11/21.
//

import Foundation
@testable import EssentialFeed

class FeedStoreSpy: FeedStore {

    enum ReceivedMessages: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    var receivedMessages = [ReceivedMessages]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrivalCompletions = [RetrivalCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion ) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func completionDeletion(error: NSError, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completionDeletionSuccesfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func completionInsertion(error: NSError, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completionInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func retrieve(completion: @escaping RetrivalCompletion) {
        receivedMessages.append(.retrieve)
        retrivalCompletions.append(completion)
    }
    
    func completionRetrival(error: NSError, at index: Int = 0) {
        retrivalCompletions[index](.failure(error))
    }
    
    func completionWithEmptyCache(at index: Int = 0) {
        retrivalCompletions[index](.success(.none))
    }
    
    func completionRetrival(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrivalCompletions[index](.success(CacheResult(feed, timestamp)))
    }

}
