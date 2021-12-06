//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by MK on 06/12/21.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

final class FeedPresenter {

    private let feedLoader: FeedLoader
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var loadingView: FeedLoadingView?
    var feedView: FeedView?

    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }

            self?.loadingView?.display(isLoading: false)
        }
    }
}
