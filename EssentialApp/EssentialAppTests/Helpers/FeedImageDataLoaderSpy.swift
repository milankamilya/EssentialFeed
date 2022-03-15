//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by MK on 15/03/22.
//

import EssentialFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
    var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    var loadedURLs: [URL] {
        return messages.map { $0.url }
    }
    var cancelledURLS = [URL]()
    
    private struct FeedImageDataLoaderTaskStub: FeedImageDataLoaderTask {
        let cancellable: () -> Void
        func cancel() {
            cancellable()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        messages.append((url, completion))
        return FeedImageDataLoaderTaskStub { [weak self] in
            self?.cancelledURLS.append(url)
        }
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
}
