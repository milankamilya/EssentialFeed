//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by MK on 14/12/21.
//

import Foundation
import Combine
import EssentialFeediOS
import EssentialFeed

class LoaderSpy: FeedImageDataLoader {
    
    // MARK: - FeedLoader
    
    private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
    private var loadMoreRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()

    var loadFeedCallCount: Int {
        return feedRequests.count
    }
    
    var loadMoreCallCount: Int {
        return loadMoreRequests.count
    }
 
    func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
        let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
        feedRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeFeedLoading(with images: [FeedImage] = [], at index: Int = 0) {
        feedRequests[index].send(Paginated(items: images, loadMorePublisher: { [weak self] in
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            self?.loadMoreRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }))
        feedRequests[index].send(completion: .finished)
    }
    
    func completeFeedLoadingWithError(at index: Int) {
        let error = NSError(domain: "an error", code: 0)
        feedRequests[index].send(completion: .failure(error))
    }

    func completeLoadMore(with images: [FeedImage] = [], lastPage: Bool = false, at index: Int = 0) {
        loadMoreRequests[index].send(Paginated(
            items: images,
            loadMorePublisher: lastPage ? nil : { [weak self] in
                let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                self?.loadMoreRequests.append(publisher)
                return publisher.eraseToAnyPublisher()
            }))
    }
    
    func completeLoadMoreWithError(at index: Int) {
        let error = NSError(domain: "an error", code: 0)
        loadMoreRequests[index].send(completion: .failure(error))
    }
    // MARK: - FeedImageDataLoader
    
    private struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallback: () -> Void
        
        func cancel() {
            cancelCallback()
        }
    }
    
    private(set) var imageRequests = [(url: URL, completion:(FeedImageDataLoader.Result) -> Void)]()
    var loadedImageURLs : [URL] {
        return imageRequests.map { $0.url }
    }
    private(set) var cancelledImageURLs = [URL]()

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "any-domain", code: 0)
        imageRequests[index].completion(.failure(error))
    }
}
