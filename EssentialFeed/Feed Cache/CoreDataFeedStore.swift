//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by MK on 18/11/21.
//

import Foundation
import CoreData

private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}


private class ManagedImageFeed: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var  location: String?
    @NSManaged var url: URL
    
    @NSManaged var cache: ManagedCache
}

public final class CoreDataFeedStore: FeedStore {
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrivalCompletion) {
        completion(.empty)
    }
}
