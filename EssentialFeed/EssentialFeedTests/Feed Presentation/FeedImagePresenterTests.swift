//
//  FeedImagePresenter.swift
//  EssentialFeedTests
//
//  Created by MK on 21/12/21.
//

import Foundation
import XCTest
@testable import EssentialFeed


struct FeedImageViewModel<Image> {
    let image: Image?
    let description: String?
    let location: String?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}

protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

private final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    
    init(view: View) {
        self.view = view
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
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendAnyMessage() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected init doesn't send any message, but sent \(view.messages) instead")
    }
    
    func test_didStartLoadingImageData_displayTextAndStartLoading() {
        let (sut, view) = makeSUT()
        let feedImage = uniqueImage()
        let expectedFeedImageViewModel = FeedImageViewModel<ViewSpy.Image>(image: nil, description: feedImage.description, location: feedImage.location, isLoading: true, shouldRetry: false)
        
        sut.didStartLoadingImageData(model: feedImage)
        
        XCTAssertEqual(view.messages, [.display(expectedFeedImageViewModel)])
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, ImageStub>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        return (sut, view)
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

extension FeedImageViewModel : Equatable where Image : Equatable {
    
}
