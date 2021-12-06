//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by MK on 03/12/21.
//

import EssentialFeed
import UIKit

final public class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {

        let presentationAdapter = FeedLoaderPresentationAdapter(loader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        let presenter = FeedPresenter(
            loadingView: WeakRefVirtualProxy(refreshController),
            feedView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader))
        
        presentationAdapter.presenter = presenter
        
        return feedController
    }
}

private final class FeedViewAdapter: FeedView {
    weak var controller: FeedViewController?
    let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { FeedImageCellController(viewModel: FeedImageViewModel<UIImage>(model: $0, imageLoader: imageLoader, imageTransformer: UIImage.init)) }
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView  {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    let loader: FeedLoader
    var presenter: FeedPresenter?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        loader.load { [weak self] result in
            
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(feed)
            
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
