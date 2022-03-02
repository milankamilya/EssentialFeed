//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by MK on 02/03/22.
//

import Foundation
import EssentialFeed

public class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader
    
    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapper: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapper?.cancel()
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let taskWrapper = TaskWrapper()
        taskWrapper.wrapper = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)

            case .failure:
                taskWrapper.wrapper = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        return taskWrapper
    }
}
