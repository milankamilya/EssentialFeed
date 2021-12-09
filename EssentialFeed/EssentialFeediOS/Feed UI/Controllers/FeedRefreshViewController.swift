//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by MK on 03/12/21.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    @IBOutlet weak var view: UIRefreshControl?

    var delegate: FeedRefreshViewControllerDelegate?
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
    
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
}
