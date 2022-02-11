//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by MK on 18/11/21.
//

import Foundation
import CoreData

public final class CoreDataFeedStore {
    private let persistanceContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL url: URL) throws {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        persistanceContainer = try NSPersistentContainer.load(modelName: "FeedStore", url: url, in: bundle)
        context = persistanceContainer.newBackgroundContext()
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
