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
    public typealias LoadResults = LoadFeedResult
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(feed: [FeedImage], completion: @escaping (SavedResults) -> Void) {
        store.deleteCachedFeed { [weak self](error) in
            guard let self = self else { return }

            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache( feed, with: completion)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResults) -> Void) {
        store.retrieve { error in
            if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SavedResults) -> Void) {
        store.insert(feed: feed.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}
