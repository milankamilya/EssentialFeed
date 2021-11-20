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
        deletionCompletions[index](error)
    }
    
    func completionDeletionSuccesfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completionInsertion(error: NSError, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completionInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func retrieve(completion: @escaping RetrivalCompletion) {
        receivedMessages.append(.retrieve)
        retrivalCompletions.append(completion)
    }
    
    func completionRetrival(error: NSError, at index: Int = 0) {
        retrivalCompletions[index](.failure(error))
    }
    
    func completionWithEmptyCache(at index: Int = 0) {
        retrivalCompletions[index](.success(.empty))
    }
    
    func completionRetrival(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrivalCompletions[index](.success(.found(feed: feed, timestamp: timestamp)))
    }

}
