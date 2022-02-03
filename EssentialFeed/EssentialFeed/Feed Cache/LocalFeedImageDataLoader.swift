//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by MK on 03/02/22.
//

import Foundation

public class LocalFeedImageDataLoader {
    
    public enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    private final class Task: FeedImageDataLoaderTask {
        var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void ) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let task = Task(completion)
        
        store.retrieve(dataForURL: url) { [weak self] result in
            guard let _ = self else { return }

            task.complete(with: result
                            .mapError { _ in Error.failed }
                            .flatMap { data in data.map { .success($0) } ?? .failure(Error.notFound) })
        }

        return task
    }
    
    public typealias SaveResult = Result<Void, Swift.Error>
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) {_ in}
    }
}
