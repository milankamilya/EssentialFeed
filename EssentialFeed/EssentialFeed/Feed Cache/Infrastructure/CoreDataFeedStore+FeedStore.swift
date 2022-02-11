//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by MK on 11/02/22.
//

import Foundation

extension CoreDataFeedStore: FeedStore {

    public func retrieve(completion: @escaping RetrivalCompletion) {
        perform { context in
            completion( Result(catching: {
                try ManagedCache.find(in: context).map {
                    CacheResult($0.localFeed, $0.timestamp)
                }
            }))
        }
    }
    
    public func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion( Result(catching: {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)

                try context.save()
            }))
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion( Result(catching: {
                try ManagedCache.find(in: context).map(context.delete)
            }))
        }
    }
    
}
