//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by MK on 07/12/21.
//

import Foundation
import EssentialFeed
import UIKit


protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    typealias ImageTransformer = (Data) -> Image?
    
    private let imageTransformer: ImageTransformer
    private let view: View
    
    init(view: View, imageTransformer: @escaping ImageTransformer) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(model: FeedImage) {
        view.display(FeedImageViewModel<Image>(
            image: nil,
            description: model.description,
            location: model.location,
            isLoading: true,
            shouldRetry: false
        ))
    }
    
    private struct InvalidImageDataError: Error { }
    
    func didFinishLoadingImageData(with data: Data, model: FeedImage) {
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
    
    func didFinishLoadingImageData(with error: Error, model: FeedImage) {
        view.display(FeedImageViewModel<Image>(
            image: nil,
            description: model.description,
            location: model.location,
            isLoading: false,
            shouldRetry: true
        ))
    }
    
}
