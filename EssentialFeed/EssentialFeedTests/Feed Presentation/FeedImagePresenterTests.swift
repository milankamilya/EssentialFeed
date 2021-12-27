//
//  FeedImagePresenter.swift
//  EssentialFeedTests
//
//  Created by MK on 21/12/21.
//

import Foundation
import XCTest
@testable import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendAnyMessage() {
        let (_, view) = makeSUT(with: { _ in ImageStub() })
        
        XCTAssertTrue(view.messages.isEmpty, "Expected init doesn't send any message, but sent \(view.messages) instead")
    }
    
    func test_didStartLoadingImageData_displayTextAndStartLoading() {
        let (sut, view) = makeSUT(with: { _ in ImageStub() })
        let feedImage = uniqueImage()
        let expectedFeedImageViewModel = getInitialViewModel(for: feedImage)
        
        sut.didStartLoadingImageData(model: feedImage)
        
        XCTAssertEqual(view.messages, [.display(expectedFeedImageViewModel)])
    }
    
    func test_didFinishLoadinImageData_displayImageAndStopLoading() {
        
        let feedImage = uniqueImage()
        let image = ImageStub()
        let (sut, view) = makeSUT(with: { _ in image })
        let expectedFeedImageViewModel = getFinishImageLoadingViewModel(for: feedImage, with: image)
        
        sut.didFinishLoadingImageData(with: Data(), model: feedImage)
        
        XCTAssertEqual(view.messages, [.display(expectedFeedImageViewModel)])
    }
    
    func test_didFinishLoadinImageData_displayRetryandStopLoading() {
        let feedImage = uniqueImage()
        let image = ImageStub()
        let error = anyNSError()
        let (sut, view) = makeSUT(with: { _ in image })
        let expectedFeedImageViewModel = getFinishImageLoadingViewModel(with: error, model: feedImage)
        
        sut.didFinishLoadingImageData(with: error, model: feedImage)
        
        XCTAssertEqual(view.messages, [.display(expectedFeedImageViewModel)])
    }
    
    // MARK: - Helpers
    private func makeSUT(with imageTransformer: @escaping (Data) -> FeedImagePresenterTests.ViewSpy.Image?, file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, ImageStub>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        return (sut, view)
    }
    
    private func getInitialViewModel(for feedImage: FeedImage) -> FeedImageViewModel<ViewSpy.Image> {
        return FeedImageViewModel<ViewSpy.Image>(image: nil, description: feedImage.description, location: feedImage.location, isLoading: true, shouldRetry: false)
    }
    
    private func getFinishImageLoadingViewModel(for feedImage: FeedImage, with image: ImageStub) -> FeedImageViewModel<ViewSpy.Image> {
        return FeedImageViewModel<ViewSpy.Image>(image: image, description: feedImage.description, location: feedImage.location, isLoading: false, shouldRetry: false)
    }
    
    private func getFinishImageLoadingViewModel(with error: Error, model: FeedImage) -> FeedImageViewModel<ViewSpy.Image> {
        return FeedImageViewModel<ViewSpy.Image>(image: nil, description: model.description, location: model.location, isLoading: false, shouldRetry: true)
    }
    
    private class ImageStub : Equatable {
        static func == (lhs: FeedImagePresenterTests.ImageStub, rhs: FeedImagePresenterTests.ImageStub) -> Bool {
            return true
        }
    }
    
    private class ViewSpy: FeedImageView {
        
        typealias Image = ImageStub
        
        enum Message: Equatable {
            case display(FeedImageViewModel<Image>)
        }

        var messages = [Message]()
        
        func display(_ viewModel: FeedImageViewModel<Image>) {
            messages.append(.display(viewModel))
        }
    }
}

