//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by MK on 03/12/21.
//

import EssentialFeed
import UIKit
import EssentialFeediOS
import Combine

final public class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> ListViewController {

        let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: feedLoader)
        
        let feedController = makeFeedViewController(
            delegate: presentationAdapter,
            title: FeedPresenter.title)
        
        presentationAdapter.presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(feedController),
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: imageLoader),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map)
        
        return feedController
    }
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
