//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by MK on 13/11/21.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion )
    func insert(items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
