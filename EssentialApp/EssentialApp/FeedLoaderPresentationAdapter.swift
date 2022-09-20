//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by MK on 15/12/21.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let loader: () -> AnyPublisher<[FeedImage], Error>
    var presenter: FeedPresenter?
    
    private var cancellable: Cancellable?
    
    init(loader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.loader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break

                case let .failure(error):
                    self?.presenter?.didFinishLoadingFeed(with: error)
                }
            }, receiveValue: { [weak self] feed in
                self?.presenter?.didFinishLoadingFeed(feed)
            })
    }
}
