//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by MK on 14/12/21.
//

import UIKit
@testable import EssentialFeediOS

extension ListViewController {
    public override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }

    func simulateuserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
    
    var errorMessage: String? {
        return errorView.message
    }
}

extension ListViewController {
    func numberOfRenderedImageCommentsView() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: commentsSection)
    }
        
    func commentMessage(at index: Int) -> String? {
        commentView(at: index)?.messageLabel.text
    }
    
    func commentDate(at index: Int) -> String? {
        commentView(at: index)?.dateLabel.text
    }
    
    func commentUsername(at index: Int) -> String? {
        commentView(at: index)?.usernameLabel.text
    }
    
    func commentView(at row: Int) -> ImageCommentCell? {
        if numberOfRenderedImageCommentsView() == 0 {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentCell
    }
    
    private var commentsSection: Int {
        return 0
    }
}

extension ListViewController {
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: 0)?.renderedImage
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

    func numberOfRenderedFeedImageView() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        if numberOfRenderedFeedImageView() == 0 {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var feedImagesSection: Int {
        return 0
    }
}
