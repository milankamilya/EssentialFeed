//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by MK on 31/03/22.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class FeedAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(httpClient: .online(response), store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageView(), 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0)
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1)
        XCTAssertTrue(feed.canLoadMoreFeed)
        
        feed.simulateLoadMoreFeedAction()
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageView(), 3)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0)
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1)
        XCTAssertEqual(feed.renderedFeedImageData(at: 2), makeImageData2)
        XCTAssertTrue(feed.canLoadMoreFeed)
        
        feed.simulateLoadMoreFeedAction()
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageView(), 3)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0)
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1)
        XCTAssertEqual(feed.renderedFeedImageData(at: 2), makeImageData2)
        XCTAssertFalse(feed.canLoadMoreFeed)
    }
    
    func test_onLaunch_displaysCachedFeedWhenCustomerHasNoConnectivity() {
        let sharedStore: InMemoryFeedStore = .empty
        let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)
        onlineFeed.simulateLoadMoreFeedAction()
        onlineFeed.simulateFeedImageViewVisible(at: 2)
        
        let offlineFeed = launch(httpClient: .offline, store: sharedStore)
        
        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageView(), 3)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData0)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData1)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 2), makeImageData2)
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let feed = launch(httpClient: .offline, store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageView(), 0)
    }
    
    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryFeedStore.withExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNil(store.feedCache, "Expected to delete expired cache")
    }
    
    func test_onEnteringBackground_keepsNonExpiredFeedCache() {
        let store = InMemoryFeedStore.withNonExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
    }
    
    func test_onFeedImageSelection_displaysComments() {
        let comments = showCommentsForFirstImage()
        
        XCTAssertEqual(comments.numberOfRenderedImageCommentsView(), 1)
        XCTAssertEqual(comments.commentMessage(at: 0), makeCommentMessage())
    }
    
    // MARK: - Helpers
    
    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: InMemoryFeedStore = .empty
    ) -> ListViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        let feed = nav?.topViewController as! ListViewController
        return feed
    }
    
    private func enterBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }
    
    private func showCommentsForFirstImage() -> ListViewController {
        let feed = launch(httpClient: .online(response), store: .empty)
        
        feed.simulateTapOnFeedImage(at: 0)
        RunLoop.current.run(until: Date())
        
        let nav = feed.navigationController
        return nav?.topViewController as! ListViewController
    }
    
    private func response(_ url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.path {
        case "/image-0": return makeImageData0
        case "/image-1": return makeImageData1
        case "/image-2": return makeImageData2
            
        case "/essential-feed/v1/feed" where url.query?.contains("after_id") == false:
            return makeFirstFeedPageData()

        case "/essential-feed/v1/feed" where url.query?.contains("after_id=CBF52DBA-490A-11ED-B878-0242AC120002") == true:
            return makeSecondFeedPageData()
            
        case "/essential-feed/v1/feed" where url.query?.contains("after_id=A4CAA32C-5F18-11ED-9B6A-0242AC120002") == true:
            return makeLastEmptyFeedPageData()
            
        case "/essential-feed/v1/image/CBF52AF4-490A-11ED-B878-0242AC120002/comments",
            "/essential-feed/v1/image/CBF52DBA-490A-11ED-B878-0242AC120002/comments":
            return makeCommentsData()
            
        default:
            return Data()
        }
    }
    
    private let makeImageData0: Data = {
        UIImage.make(withColor: .red).pngData()!
    }()
    private let makeImageData1: Data = {
        UIImage.make(withColor: .green).pngData()!
    }()
    private let makeImageData2: Data = {
        UIImage.make(withColor: .blue).pngData()!
    }()
    
    private func makeFirstFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [ "items": [
            ["id": "CBF52AF4-490A-11ED-B878-0242AC120002", "image": "http://image.com/image-0"],
            ["id": "CBF52DBA-490A-11ED-B878-0242AC120002", "image": "http://image.com/image-1"]
        ]])
    }

    private func makeSecondFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [ "items": [
            ["id": "A4CAA32C-5F18-11ED-9B6A-0242AC120002", "image": "http://image.com/image-2"]
        ]])
    }
    
    private func makeLastEmptyFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [ "items": []])
    }
    
    private func makeCommentsData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [ "items": [
            [
                "id": UUID().uuidString,
                "message": makeCommentMessage(),
                "created_at": "2020-05-20T11:24:59+0000",
                "author": [
                    "username": "a username"
                ]
            ]
        ]])
    }
    
    private func makeCommentMessage() -> String {
        return "a message"
    }
    
    private class HTTPClientStub: HTTPClient {
        private class Task: HTTPClientTask {
            func cancel() { }
        }
        
        private let stub: (URL) -> HTTPClient.Result
        
        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }
        
        static var offline: HTTPClientStub {
            HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
        }
        
        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub(stub: { url in .success(stub(url))})
        }
    }
    
    private class InMemoryFeedStore: FeedStore, FeedImageDataStore {
        
        var feedCache: CacheResult?
        private var feedImageDataCache: [URL: Data] = [:]
        
        convenience init(feedCache: CacheResult) {
            self.init()
            self.feedCache = feedCache
        }
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            feedCache = nil
            completion(.success(()))
        }
        
        func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
            feedCache = CacheResult(feed: feed, timestamp: timestamp)
            completion(.success(()))
        }
        
        func retrieve(completion: @escaping RetrivalCompletion) {
            completion(.success(feedCache))
        }
        
        func retrieve(dataForURL: URL, completion: @escaping (RetrieveResult) -> Void) {
            completion(.success(feedImageDataCache[dataForURL]))
        }
        
        func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
            feedImageDataCache[url] = data
            completion(.success(()))
        }
        
        static var empty: InMemoryFeedStore {
            InMemoryFeedStore()
        }
        
        static var withExpiredFeedCache: InMemoryFeedStore {
            InMemoryFeedStore(feedCache: CacheResult(feed: [], timestamp: Date.distantPast))
        }
        
        static var withNonExpiredFeedCache: InMemoryFeedStore {
            InMemoryFeedStore(feedCache: CacheResult(feed: [], timestamp: Date()))
        }
    }
    
    
}
