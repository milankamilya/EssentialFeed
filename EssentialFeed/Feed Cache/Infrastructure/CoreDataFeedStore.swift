//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by MK on 18/11/21.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    private let persistanceContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init(storeURL url: URL, bundle: Bundle = .main) throws {
        persistanceContainer = try NSPersistentContainer.load(modelName: "FeedStore", url: url, in: bundle)
        context = persistanceContainer.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrivalCompletion) {
        perform { context in
            completion( Result(catching: {
                try ManagedCache.find(in: context).map {
                    return CacheResult($0.localFeed, $0.timestamp)
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
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
