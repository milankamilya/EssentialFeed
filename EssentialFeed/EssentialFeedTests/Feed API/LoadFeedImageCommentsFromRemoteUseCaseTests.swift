//
//  LoadFeedImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by MK on 25/04/22.
//

import XCTest
import EssentialFeed

class LoadFeedImageCommentsFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotReqeuestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load {_ in}
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load {_ in}
        sut.load {_ in}
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompeteWithResult: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 150, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompeteWithResult: failure(.invalidData)) {
                let validateData = makeItemsJSON(items: [])
                client.complete(withStatusCode: code, data: validateData, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        let samples = [200, 201, 250, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompeteWithResult: failure(.invalidData)) {
                let invalidJSON = Data( "invalid json".utf8)
                client.complete(withStatusCode: code, data: invalidJSON, at: index)
            }
        }
    }
    
    func test_load_deliversNoitemsON2xxHTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        let samples = [200, 201, 250, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompeteWithResult: .success([])) {
                let emptyListJSON = makeItemsJSON(items: [])
                client.complete(withStatusCode: code, data: emptyListJSON, at: index)
            }
        }
    }
    
    func test_load_deliversFeeditemsON2xxHTTPResponseJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!)
 
        let items = [item1.json, item2.json]

        let samples = [200, 201, 250, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompeteWithResult: .success([item1.model, item2.model])) {
                let json = makeItemsJSON(items: items)
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)
        
        var capturedResults = [RemoteImageCommentsLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON(items: []))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        
        let json = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.url.absoluteString
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteImageCommentsLoader, toCompeteWithResult expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems)

            case let (.failure(receivedItems as RemoteImageCommentsLoader.Error), .failure(expectedItems as RemoteImageCommentsLoader.Error)):
                XCTAssertEqual(receivedItems, expectedItems)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }

}
