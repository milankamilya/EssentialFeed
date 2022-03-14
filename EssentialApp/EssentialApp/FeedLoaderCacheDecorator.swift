//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by MK on 14/03/22.
//

import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
    let decoratee: FeedLoader
    let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map { feed in
                self?.cache.save(feed: feed) { _ in }
                return feed
            })
        }
    }
}
