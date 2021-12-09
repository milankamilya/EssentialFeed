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
    
    private var cell: FeedImageCell?
    
    func view(in tableView: UITableView ) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelRequestImage()
    }
    
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell?.feedImageView.setImageAnimated(viewModel.image)
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
    }
    
    func releaseCellForReuse() {
        cell = nil
    }
}
