//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by MK on 28/02/22.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapper: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapper?.cancel()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
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

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let (_, primary, fallback) = makeSUT()
                
        XCTAssertTrue(primary.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallback.loadedURLs.isEmpty, "Expected no loaded URLs in the fallable loader")
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let url = anyURL()
        let (sut, primary, fallback) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in}
        
        XCTAssertEqual(primary.loadedURLs, [url], "Expected to load URLs from primary loader")
        XCTAssertTrue(fallback.loadedURLs.isEmpty, "Expected no loaded URLs in the fallable loader")
    }
    
    func test_loadImageData_loadsFallbackLoaderOnPrimaryLoaderFailure() {
        let url = anyURL()
        let primaryError = anyNSError()
        let (sut, primary, fallback) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in}
        
        primary.complete(with: primaryError)
        
        XCTAssertEqual(primary.loadedURLs, [url], "Expected to load URLs from primary loader")
        XCTAssertEqual(fallback.loadedURLs, [url], "Expected to load URLs from fallable loader")
    }
    
    func test_loadIamgeData_cancelsPrimaryTaskOnCancel() {
        let url = anyURL()
        let (sut, primary, fallback) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in}
        
        task.cancel()
        
        XCTAssertEqual(primary.cancelledURLS, [url], "Expected to cancel URL loading from primary loader")
        XCTAssertTrue(fallback.cancelledURLS.isEmpty, "Expected no cancelled URL loading in the fallable loader")
    }
    
    func test_loadImageData_cancelsFallableLoaderTaskAfterPrimaryLoaderFailure() {
        let url = anyURL()
        let primaryError = anyNSError()
        let (sut, primary, fallback) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in}
        
        primary.complete(with: primaryError)
        
        task.cancel()
        
        XCTAssertTrue(primary.cancelledURLS.isEmpty, "Expected no cancelled URLs in the primary loader")
        XCTAssertEqual(fallback.cancelledURLS, [url], "Expected to cancel URL loading from fallable loader")
    }
    
    func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
        let primaryData = anyData()
        let (sut, primary, _) = makeSUT()
        
        expect(sut, toCompleteWith: .success(primaryData)) {
            primary.complete(with: primaryData)
        }
    }
    
    func test_loadImageData_deliversFallableDataOnFallableLoaderSuccess() {
        let primaryError = anyNSError()
        let fallableData = anyData()
        let (sut, primary, fallable) = makeSUT()
        
        expect(sut, toCompleteWith: .success(fallableData)) {
            primary.complete(with: primaryError)
            fallable.complete(with: fallableData)
        }
    }
    
    func test_loadImageData_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
        let primaryError = anyNSError()
        let fallbackError = anyNSError()
        let (sut, primary, fallback) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(fallbackError)) {
            primary.complete(with: primaryError)
            fallback.complete(with: fallbackError)
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT( _ file: StaticString = #file, line: UInt = #line) -> (FeedImageDataLoaderWithFallbackComposite, FeedImageDataLoaderSpy, FeedImageDataLoaderSpy) {
        let primaryLoader = FeedImageDataLoaderSpy()
        let fallbackLoader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
    
    private func expect(_ sut: FeedImageDataLoaderWithFallbackComposite, toCompleteWith expectedResult: FeedImageDataLoader.Result, on action: () -> Void, _ file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Waiting for image loading")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, "Expected to receive \(expectedData)", file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected to receive \(expectedResult), but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    
    private struct FeedImageDataLoaderTaskStub: FeedImageDataLoaderTask {
        let cancellable: () -> Void
        func cancel() {
            cancellable()
        }
    }
    
    class FeedImageDataLoaderSpy: FeedImageDataLoader {
        var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        var loadedURLs: [URL] {
            return messages.map { $0.url }
        }
        var cancelledURLS = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return FeedImageDataLoaderTaskStub { [weak self] in
                self?.cancelledURLS.append(url)
            }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
    }
    
}

