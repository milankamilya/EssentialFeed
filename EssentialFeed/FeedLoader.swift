//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by MK on 01/11/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoadrer {
    func load(completion: @escaping () -> Void)
}
