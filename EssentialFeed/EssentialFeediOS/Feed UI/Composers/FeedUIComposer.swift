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
        controller?.tableModel = viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: self.imageLoader)
            let cellController = FeedImageCellController(delegate: adapter)

            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(cellController),
                imageTransformer: UIImage.init)
            
            return cellController
        }
    }
}

class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(model: model)
        
        task = imageLoader.loadImageData(from: self.model.url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(data):
                self.presenter?.didFinishLoadingImageData(with: data, model: self.model)
                
            case let .failure(error):
                self.presenter?.didFinishLoadingImageData(with: error, model: self.model)
            }
        }
    }
    
    func didCancelRequestImage() {
        task?.cancel()
        task = nil
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

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
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
