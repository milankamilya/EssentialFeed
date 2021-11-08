//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by MK on 07/11/21.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedvaluesRepresentation: Error { }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedvaluesRepresentation()))
            }
        } .resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETReqeustWithURL() {
        
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = NSError(domain: "any error", code: 1)
        guard let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as NSError? else {
            XCTFail("Expected failure with \(requestError), got no error instead")
            return
        }
        
        XCTAssertEqual(receivedError.domain, requestError.domain)
        XCTAssertEqual(receivedError.code, requestError.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        let nonHTTPURLResponse = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let anyHTTPURLResponse = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: [:])
        let anyData = Data("any data".utf8)
        let anyError = NSError(domain: "any error", code: 1)

        XCTAssertNotNil( resultErrorFor(data: nil, response: nil, error: nil) )
        XCTAssertNotNil( resultErrorFor(data: nil, response: nonHTTPURLResponse, error: nil) )
        XCTAssertNotNil( resultErrorFor(data: nil, response: anyHTTPURLResponse, error: nil) )
        XCTAssertNotNil( resultErrorFor(data: anyData, response: nil, error: nil) )
        XCTAssertNotNil( resultErrorFor(data: anyData, response: nil, error: anyError) )
        XCTAssertNotNil( resultErrorFor(data: nil, response: nonHTTPURLResponse, error: anyError) )
        XCTAssertNotNil( resultErrorFor(data: nil, response: anyHTTPURLResponse, error: anyError) )
        XCTAssertNotNil( resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: anyError) )
        XCTAssertNotNil( resultErrorFor(data: anyData, response: anyHTTPURLResponse, error: anyError) )
        XCTAssertNotNil( resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: nil) )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)

        var capturedError: Error?
        let exp = expectation(description: "Wait for completion")
        
        makeSUT(file: file, line: line).get(from: anyURL()) { result in
            switch result {
            case let .failure(receivedError as NSError):
                capturedError = receivedError
            default:
                XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        return capturedError
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private class URLProtocolStub: URLProtocol {
        static var stub: Stub?
        static var requestObserver: ((URLRequest) -> Void)?
        
        struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    
}
