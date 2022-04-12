//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by MK on 15/12/21.
//

import Foundation
import Combine
import EssentialFeed
import EssentialFeediOS

class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    
    private var cancellable: Cancellable?
    private let model: FeedImage
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(model: model)
        
        let model = self.model
        
        cancellable = imageLoader(model.url)
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case let .failure(error):
                    self?.presenter?.didFinishLoadingImageData(with: error, model: model)
                }
            } receiveValue: { [weak self] data in
                self?.presenter?.didFinishLoadingImageData(with: data, model: model)
            }
    }
    
    func didCancelRequestImage() {
        cancellable?.cancel()
    }

}
