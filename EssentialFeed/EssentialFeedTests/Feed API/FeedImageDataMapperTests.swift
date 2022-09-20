//
//  FeedImageDataMapperTests.swift
//  EssentialFeedTests
//
//  Created by MK on 20/09/22.
//

import XCTest
import EssentialFeed

class FeedImageDataMapperTests: XCTestCase {
    func test_map_throwsInvalidDataErrorOnNon200HTTPResponse() throws {
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedImageDataMapper.map(anyData(), from: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_throwsInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let emptyData = Data("".utf8)
        
        XCTAssertThrowsError(
            try FeedImageDataMapper.map(emptyData, from: HTTPURLResponse(statusCode: 200))
        )
    }

    func test_loadImageDataFromURL_deliversAndReceiveNonEmptyDataOn200HTTPResponse() {
        let nonEmptyData = Data("non empty data".utf8)

        XCTAssertNoThrow(
            try FeedImageDataMapper.map(nonEmptyData, from: HTTPURLResponse(statusCode: 200))
        )
    }
}
