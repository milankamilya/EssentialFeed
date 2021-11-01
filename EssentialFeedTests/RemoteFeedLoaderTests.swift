//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by MK on 01/11/21.
//

import XCTest

class RemoteFeedLoader{
    let client: HTTPClient
    let url: URL
    
    init(url: URL = URL(string: "http://a-url.com")!, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL?)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL?) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotReqeuestDataFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "http://a-url.com")
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url!, client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
        XCTAssertEqual(client.requestedURL, url)
    }

}
