//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by MK on 01/11/21.
//

import XCTest

class RemoteFeedLoader{
    func load() {
        HTTPClient.shared.get(from: URL(string: "http://a-url.com"))
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    
    func get(from url: URL?) {    }
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    override func get(from url: URL?) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotReqeuestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
