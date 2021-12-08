//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by MK on 03/12/21.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelRequestImage()
}

final class FeedImageCellController: FeedImageView {
    typealias Image = UIImage
    
    private let delegate: FeedImageCellControllerDelegate
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    private lazy var cell = FeedImageCell()
    
    func view() -> UITableViewCell {
        let localCell = loadView(cell)
        delegate.didRequestImage()
        return localCell
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelRequestImage()
    }
    
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell.feedImageView.image = viewModel.image
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.feedImageContainer.isShimmering = viewModel.isLoading
        cell.feedImageRetryButton.isHidden = !viewModel.shouldRetry
    }
    
    private func loadView(_ cell: FeedImageCell) -> FeedImageCell {
        cell.onRetry = delegate.didRequestImage
        return cell
    }
}
