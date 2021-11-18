//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by MK on 18/11/21.
//

import Foundation
import CoreData

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

@objc(ManagedFeedImage)
private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var  location: String?
    @NSManaged var url: URL
    
    @NSManaged var cache: ManagedCache
}

public final class CoreDataFeedStore: FeedStore {
    private let persistanceContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init(storeURL url: URL, bundle: Bundle = .main) throws {
        persistanceContainer = try NSPersistentContainer.load(modelName: "FeedStore", url: url, in: bundle)
        context = persistanceContainer.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrivalCompletion) {
        let context = self.context
        context.perform {
            do {
                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                request.returnsObjectsAsFaults = false
                if let cache = try context.fetch(request).first {
                    completion(.found(
                        feed: cache.feed
                            .compactMap { ($0 as? ManagedFeedImage) }
                            .map {
                                LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, url: $0.url)
                            },
                        timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch let error {
                completion(.failure(error: error))
            }
        }
    }
    
    public func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let context = self.context
        context.perform {
            do {
                let managedCache = ManagedCache(context: context)
                managedCache.timestamp = timestamp
                managedCache.feed = NSOrderedSet(array: feed.map { local in
                    let managed = ManagedFeedImage(context: context)
                    managed.id = local.id
                    managed.imageDescription = local.description
                    managed.location = local.location
                    managed.url = local.url
                    return managed
                })
                
                try context.save()
                completion(nil)
            } catch let error {
                completion(error)
            }
        }
    }
}

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
