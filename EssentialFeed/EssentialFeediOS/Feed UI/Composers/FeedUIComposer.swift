//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by MK on 03/12/21.
//

import EssentialFeed

final public class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map { FeedImageCellController(model: $0, imageLoader: imageLoader) }
        }
        return feedController
    }
}
