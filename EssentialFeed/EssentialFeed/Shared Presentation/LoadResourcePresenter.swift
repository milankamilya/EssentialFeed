//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by MK on 20/09/22.
//

import Foundation


public protocol ResourceView {
    func display(_ viewModel: String)
}

public final class LoadResourcePresenter {
    public typealias Mapper = (String) -> String

    let loadingView: FeedLoadingView
    let resourceView: ResourceView
    let errorView: FeedErrorView
    let mapper: Mapper

    public init(loadingView: FeedLoadingView, resourceView: ResourceView, errorView: FeedErrorView, mapper: @escaping Mapper) {
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    private var feedLoadError: String {
        return NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: LoadResourcePresenter.self),
            comment: "Error message when you can't load image feed from server")
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: String) {
        resourceView.display(mapper(resource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
