//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by MK on 15/12/21.
//

import Foundation
import EssentialFeed

class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(model: model)
        
        task = imageLoader.loadImageData(from: self.model.url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(data):
                self.presenter?.didFinishLoadingImageData(with: data, model: self.model)
                
            case let .failure(error):
                self.presenter?.didFinishLoadingImageData(with: error, model: self.model)
            }
        }
    }
    
    func didCancelRequestImage() {
        task?.cancel()
        task = nil
    }

}
