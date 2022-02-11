//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by MK on 04/02/22.
//

import XCTest
import EssentialFeed

final class CoreDataFeedImageDataStoreTests: XCTestCase {

    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: notFound())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "http://a-url.com")!
        let notMatchingURL = URL(string: "http://another-url.com")!
        
        insert(anyData(), for: url, into: sut)
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: notMatchingURL)
    }
    
    func test_retrieveImageData_deliversFoundDataWhenThereIsAImageMatchingURL() {
        let sut = makeSUT()
        let storedData = anyData()
        let matchingURL = URL(string: "http://a-url.com")!
        
        insert(storedData, for: matchingURL, into: sut)
        
        expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingURL)
    }
    
    func test_retrieveImageData_deliversLastInsertedValue() {
        let sut = makeSUT()
        let firstData = Data("first".utf8)
        let lastData = Data("last".utf8)
        let url = URL(string: "http://a-url.com")!
        
        insert(firstData, for: url, into: sut)
        insert(lastData, for: url, into: sut)
        
        expect(sut, toCompleteRetrievalWith: found(lastData), for: url)
    }
    
    func test_sideEffects_runSerially() {
        let sut = makeSUT()
        let url = anyURL()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(feed: [localImage(url: url)], timestamp: Date()) { _ in
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.insert(anyData(), for: url) { _ in op2.fulfill() }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(anyData(), for: url) { _ in op3.fulfill() }
        
        wait(for: [op1, op2, op3], timeout: 5.0, enforceOrder: true)
    }
    
    // MARK: - Helpers
    
    private func found(_ data: Data) -> FeedImageDataStore.RetrieveResult {
        return .success(data)
    }
    
    private func notFound() -> FeedImageDataStore.RetrieveResult {
        return .success(.none)
    }
    
    private func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrieveResult, for url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for retrieval")
        
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedData), .success(receivedData)):
                XCTAssertEqual(expectedData, receivedData, file: file, line: line)
            
            default:
                XCTFail("Expected to receive \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache insertion")
        let image = localImage(url: url)
        
        sut.insert(feed: [image], timestamp: Date()) { result in
            switch result {
            case .success:
                sut.insert(data, for: url) { result in
                    if case let Result.failure(error) =  result {
                        XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
                    }
                    exp.fulfill()
                }
                
            case let .failure(error):
                XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
