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
        store.retrieve { [unowned self] result in
            switch result {
            case let .failure(error):
                self.store.deleteCachedFeed { _ in }
                completion(.failure(error))

            case let .found(feed, timestamp) where self.validate(timestamp):
                completion(.success(feed.toModel()))
                
            case .found, .empty:
                completion(.success([]))
            
            }
        }
    }
    
    var maxCacheAgeInDays: Int {
        return 7
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        let calender = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        
        return currentDate() < maxCacheAge
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

private extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}
