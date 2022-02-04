//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by MK on 04/02/22.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retrieve(dataForURL: URL)
        case insert(data: Data, url: URL)
    }
    var receivedMessages = [Message]()
    var retrievalCompletions = [(FeedImageDataStore.RetrieveResult) -> Void]()
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, url: url))
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult) -> Void) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve(dataForURL: url))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
}
