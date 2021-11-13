//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by MK on 13/11/21.
//

import Foundation

public class LocalFeedLoader {
    let store: FeedStore
    let currentDate: () -> Date
    
    public typealias SavedResults = Error?
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(items: [FeedItem], completion: @escaping (SavedResults) -> Void) {
        store.deleteCachedFeed { [weak self](error) in
            guard let self = self else { return }

            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache( items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (SavedResults) -> Void) {
        store.insert(items: items.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        return map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
    }
}
