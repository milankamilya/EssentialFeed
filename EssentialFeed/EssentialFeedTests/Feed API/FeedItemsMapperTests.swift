//
//  FeedItemsMapperTests.swift
//  EssentialFeedTests
//
//  Created by MK on 01/11/21.
//

import XCTest

@testable import EssentialFeed

class FeedItemsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let json = makeItemsJSON(items: [])
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(json, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data( "invalid json".utf8)

        XCTAssertThrowsError(
            try FeedItemsMapper.map(invalidJSON, HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_throwsNoitemsON200HTTPResponseWithEmptyJSONList() throws {
        let emptyListJSON = makeItemsJSON(items: [])

        let result = try FeedItemsMapper.map(emptyListJSON, HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, [])
    }
    
    func test_map_throwsFeeditemsON200HTTPResponseJSONItems() throws {
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!)
 
        let items = [item1.json, item2.json]
        let json = makeItemsJSON(items: items)

        let result = try FeedItemsMapper.map(json, HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, [item1.model, item2.model])
    }
    
    // MARK: - Helpers
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
}
