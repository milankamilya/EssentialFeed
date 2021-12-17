//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by MK on 22/11/21.
//

import UIKit


protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView, FeedErrorView {
        
    var delegate: FeedViewControllerDelegate?
    @IBOutlet private(set) public var errorView: ErrorView?

    var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    private var cellControllers = [IndexPath: FeedImageCellController]()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    func display(_ viewModel: FeedErrorViewModel) {
        errorView?.message = viewModel.message
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellController = getCellController(forRowAt: indexPath)
        return cellController.view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellController = getCellController(forRowAt: indexPath)
            cellController.preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
    
    private func getCellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        tableModel[indexPath.row].cancelLoad()
    }
}
