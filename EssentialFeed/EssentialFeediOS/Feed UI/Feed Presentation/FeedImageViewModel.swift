//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by MK on 04/12/21.
//

import Foundation
import EssentialFeed

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    typealias ImageTransformer = (Data) -> Image?
    
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: ImageTransformer
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping ImageTransformer) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var description: String? {
        return model.description
    }
    
    var location: String? {
        return model.location
    }
    
    var hasLocation: Bool {
        model.location != nil
    }
    
    var onImageLoad: Observer<Image?>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        self.onShouldRetryImageLoadStateChange?(false)
        self.onImageLoadingStateChange?(true)
        
        task = self.imageLoader.loadImageData(from: self.model.url) { [weak self] result in
            guard let self = self else { return }
            self.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
