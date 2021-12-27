//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by MK on 27/12/21.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    public typealias ImageTransformer = (Data) -> Image?
    
    private let imageTransformer: ImageTransformer
    private let view: View
    
    public init(view: View, imageTransformer: @escaping ImageTransformer) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(model: FeedImage) {
        view.display(FeedImageViewModel<Image>(
            image: nil,
            description: model.description,
            location: model.location,
            isLoading: true,
            shouldRetry: false
        ))
    }
    
    private struct InvalidImageDataError: Error { }
    
    public func didFinishLoadingImageData(with data: Data, model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), model: model)
        }
        
        view.display(FeedImageViewModel<Image>(
            image: image,
            description: model.description,
            location: model.location,
            isLoading: false,
            shouldRetry: false
        ))
    }
    
    public func didFinishLoadingImageData(with error: Error, model: FeedImage) {
        view.display(FeedImageViewModel<Image>(
            image: nil,
            description: model.description,
            location: model.location,
            isLoading: false,
            shouldRetry: true
        ))
    }
}
