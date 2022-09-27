//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by MK on 22/11/21.
//

import UIKit
import EssentialFeed

public protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public protocol CellController {
    func view(in tableView: UITableView ) -> UITableViewCell
    func preload()
    func cancelLoad()
}

final public class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
    
    private var loadingControllers = [IndexPath: CellController]()
    
    @IBOutlet private(set) public var errorView: ErrorView?

    private var tableModel = [CellController]() {
        didSet { tableView.reloadData() }
    }
    
    public var delegate: FeedViewControllerDelegate?
    
    private var cellControllers = [IndexPath: CellController]()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    
    public func display(_ cellControllers: [CellController]) {
        tableModel = cellControllers
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
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
    
    private func getCellController(forRowAt indexPath: IndexPath) -> CellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
    }
}
