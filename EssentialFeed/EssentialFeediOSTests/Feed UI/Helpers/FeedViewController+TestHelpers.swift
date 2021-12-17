//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by MK on 14/12/21.
//

import UIKit
@testable import EssentialFeediOS

extension FeedViewController {
    func simulateuserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let cell = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: cell!, forRowAt: indexPath)
        return cell
        
    }
    
    func simulateFeedImageViewNearVisible(at row: Int = 0) {
        let pds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        pds?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int = 0) {
        simulateFeedImageViewNearVisible(at: row)
        
        let pds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        pds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    var errorMessage: String? {
        return errorView.message
    }
    
    func numberOfRenderedFeedImageView() -> Int {
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var feedImagesSection: Int {
        return 0
    }
}
