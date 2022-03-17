//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by MK on 14/03/22.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(feed: [FeedImage], completion: @escaping (Result) -> Void)
}
