//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by MK on 13/11/21.
//

import Foundation

private final class FeedCachePolicy {
    
    let currentDate: () -> Date

    init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
    }
    
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
    func validate(_ timestamp: Date) -> Bool {
        let calender = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        
        return currentDate() < maxCacheAge
    }
}

public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    private let cachePolicy: FeedCachePolicy
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
        self.cachePolicy = FeedCachePolicy(currentDate: currentDate)
    }

}

extension LocalFeedLoader {
    public typealias SavedResults = Error?

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
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SavedResults) -> Void) {
        store.insert(feed: feed.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
    
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResults = LoadFeedResult

    public func load(completion: @escaping (LoadResults) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .found(feed, timestamp) where self.cachePolicy.validate(timestamp):
                completion(.success(feed.toModel()))
                
            case .found, .empty:
                completion(.success([]))
            
            }
        }
    }
    
}
    
extension LocalFeedLoader {
    
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
                
            case let .found(_, timestamp) where !self.cachePolicy.validate(timestamp):
                self.store.deleteCachedFeed { _ in }
                
            case .found, .empty: break
            }
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
