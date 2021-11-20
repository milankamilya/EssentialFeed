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
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete)
                completion(nil)
            } catch let error {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrivalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.success(.some(CacheResult(cache.localFeed, cache.timestamp))))
                } else {
                    completion(.success(.none))
                }
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)

                try context.save()
                completion(nil)
            } catch let error {
                completion(error)
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
