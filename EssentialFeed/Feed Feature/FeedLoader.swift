//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by MK on 01/11/21.
//

import Foundation

public typealias LoadFeedResult = Swift.Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
