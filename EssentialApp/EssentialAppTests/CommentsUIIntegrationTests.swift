//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by MK on 10/10/22.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
import EssentialApp
import Combine

class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    
    func test_commentView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    func test_loadCommentActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading request before the view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateuserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a load")
        
        sut.simulateuserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected third loading request once user initiates another load")
    }
    
    override func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once the view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading when it completes loading successfully")
        
        sut.simulateuserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator again when user initiated load")
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateuserInitiatedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])
        
        sut.simulateuserInitiatedReload()
        loader.completeFeedLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    override func test_loadFeedCompletion_shouldNoftAlterCurrentRenderingStateOnError() {
        let image0 = makeImage(description: "a description", location: "a location")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateuserInitiatedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
        
    }
    
    override func test_loadFeedCompletion_dispatchesFromBackgroundThreadToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Waiting for background queues")
        DispatchQueue.global().async {
            loader.completeFeedLoading()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    override func test_errorView_renderErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateuserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    override func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    // MARK: - Helper
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://a-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private class LoaderSpy {
                
        private var feedRequests = [PassthroughSubject<[FeedImage], Error>]()
        
        var loadCommentsCallCount: Int {
            return feedRequests.count
        }
     
        func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
            let publisher = PassthroughSubject<[FeedImage], Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeFeedLoading(with images: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index].send(images)
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index].send(completion: .failure(error))
        }
    }
}