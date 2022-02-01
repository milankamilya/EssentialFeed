//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by MK on 07/11/21.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.removeStub()
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
        let requestError = anyNSError()
        guard let receivedError = resultErrorFor(values: (data: nil, response: nil, error: requestError)) as NSError? else {
            XCTFail("Expected failure with \(requestError), got no error instead")
            return
        }
        
        XCTAssertEqual(receivedError.domain, requestError.domain)
        XCTAssertEqual(receivedError.code, requestError.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil( resultErrorFor(values: (data: nil, response: nil, error: nil)) )
        XCTAssertNotNil( resultErrorFor(values: (data: nil, response: nonHTTPURLResponse(), error: nil)) )
        XCTAssertNotNil( resultErrorFor(values: (data: anyData(), response: nil, error: nil)) )
        XCTAssertNotNil( resultErrorFor(values: (data: anyData(), response: nil, error: anyNSError())) )
        XCTAssertNotNil( resultErrorFor(values: (data: nil, response: nonHTTPURLResponse(), error: anyNSError())) )
        XCTAssertNotNil( resultErrorFor(values: (data: nil, response: anyHTTPURLResponse(), error: anyNSError())) )
        XCTAssertNotNil( resultErrorFor(values: (data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())) )
        XCTAssertNotNil( resultErrorFor(values: (data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())) )
        XCTAssertNotNil( resultErrorFor(values: (data: anyData(), response: nonHTTPURLResponse(), error: nil)) )
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let receivedValue = resultValuesFor(values: (data: data, response: response, error: nil))
        
        XCTAssertEqual(receivedValue?.data, data)
        XCTAssertEqual(receivedValue?.response.url, response.url)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
    }
    
    func test_getFromURL_succeedsWithHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        
        let receivedValue = resultValuesFor(values: (data: nil, response: response, error: nil))
        
        let emptyData = Data()
        XCTAssertEqual(receivedValue?.data, emptyData)
        XCTAssertEqual(receivedValue?.response.url, response.url)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
        
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let error = resultErrorFor(taskHandler: { task in
            task.cancel()
        }) as NSError?
        
        XCTAssertEqual(error?.code, URLError.cancelled.rawValue)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultValuesFor(values: (data: Data?, response: URLResponse?, error: Error?)?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        let result = resultFor(values: values, file: file, line: line)
        
        switch result {
        case let .success((data, response)):
            return (data, response)
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultErrorFor(values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in}, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(values: values, taskHandler: taskHandler,  file: file, line: line)
        
        switch result {
        case let .failure(error as NSError):
            return error

        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
            
    }
    
    private func resultFor(values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in}, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }

        var receivedResult: HTTPClient.Result!
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        taskHandler(sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1)
        return receivedResult
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: [:])!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private class URLProtocolStub: URLProtocol {

        struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
            let requestObserver: ((URLRequest) -> Void)?
        }
        
        private static var _stub: Stub?
        private static var stub: Stub? {
            get { return queue.sync { _stub } }
            set { queue.sync { _stub = newValue }}
        }
        
        private static var queue = DispatchQueue(label: "URLProtocolStub.queue")
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error, requestObserver: nil)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
        }
        
        static func removeStub() {
            stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
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
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
            
            stub.requestObserver?(request)
        }
        
        override func stopLoading() {}
    }
    
}
