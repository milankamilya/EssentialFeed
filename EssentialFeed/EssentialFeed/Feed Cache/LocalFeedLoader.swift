//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by MK on 13/11/21.
//

import Foundation

public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

}

extension LocalFeedLoader {
    public typealias SavedResults = Error?

    public func save(feed: [FeedImage], completion: @escaping (SavedResults) -> Void) {
        store.deleteCachedFeed { [weak self](deletionResult) in
            guard let self = self else { return }

            switch deletionResult {
            case .success:
                self.cache( feed, with: completion)
            
            case let .failure(error):
                completion(error)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SavedResults) -> Void) {
        store.insert(feed: feed.toLocal(), timestamp: self.currentDate()) { [weak self] insertionResult in
            guard self != nil else { return }
            
            switch insertionResult {
            case .success:
                completion(nil)
            
            case let .failure(error):
                completion(error)
            }
        }
    }
    
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResults = FeedLoader.Result

    public func load(completion: @escaping (LoadResults) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModel()))
                
            case .success:
                completion(.success([]))
            
            }
        }
    }
    
}
    
extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    
    public func validateCache(_ completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in completion(.success(())) }
                
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in completion(.success(())) }
                
            case .success:
                completion(.success(()))
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
